#
# Cookbook Name:: cacti
# Recipe:: server
#
# Contributors Brian Flad
# Copyright 2013
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Load Cacti data bag
cacti_data_bag = Chef::EncryptedDataBagItem.load("cacti","server")
cacti_admin_info = cacti_data_bag[node.chef_environment]['admin']
cacti_database_info = cacti_data_bag[node.chef_environment]['database']

# Install Cacti and dependencies
include_recipe "apache2"
include_recipe "apache2::mod_php5"
include_recipe "apache2::mod_rewrite"
include_recipe "apache2::mod_ssl"
include_recipe "mysql::client"



if platform?("ubuntu")
  package_list = %w{cacti snmp php5-snmp}
  apache_conf_dir = '/etc/apache2'
  cacti_logfile = '/var/log/cacti/cacti.log'
  cacti_docroot = '/usr/share/cacti/site'
  
  # Create parent dir for dbconfig-common if it does not exist
  directory "/etc/dbconfig-common" do
    owner "root"
    group "root"
    mode 00755
  end

  # Preeseed Debian dbconfig-common with database settings
  # Let dbconfig-common handle the cacti php config file
  # (Package hardcodes this to: /etc/cacti/debian.php)
  template "/etc/dbconfig-common/cacti.conf" do
    source "cacti_dbconfig-common.conf.erb"
    owner "root"
    group "root"
    mode 00644
    variables({
      :database => cacti_database_info
    })
    notifies :run , "execute[dpkg-reconfigure_cacti]", :delayed
    notifies :reload, "service[apache2]", :delayed
  end

elsif platform?("redhat")
  package_list = %w{ cacti net-snmp net-snmp-utils perl-LDAP perl-Net-SNMP php-ldap php-mysql php-pecl-apc php-snmp }
  apache_conf_dir = '/etc/httpd'
  cacti_logfile = '/usr/share/cacti/log/cacti.log'
  cacti_docroot = '/usr/share/cacti/'
  
  # Configure cacti.conf ourselves
  template "/etc/cacti/db.php" do
    source "db.php.erb"
    owner "cacti"
    group "apache"
    mode 00640
    variables({
      :database => cacti_database_info
    })
  end
end

package_list.each do |p|
  package p
end

execute "dpkg-reconfigure_cacti" do
  user 'root'
  group 'root'
  environment ( { "DEBIAN_FRONTEND" => 'noninteractive' } )
  command "dpkg-reconfigure cacti"
  action :nothing
end

if cacti_database_info['host'] == "localhost"
  include_recipe "mysql::server"
  include_recipe "database::mysql"
  
  cacti_database_info['port'] ||= 3306
  database_connection = {
    :host => cacti_database_info['host'],
    :port => cacti_database_info['port'],
    :username => 'root',
    :password => node['mysql']['server_root_password']
  }
  
  mysql_database cacti_database_info['name'] do
    connection database_connection
    action :create
    notifies :run, "execute[setup_cacti_database]", :immediately
  end

  if platform?("redhat")
    execute "setup_cacti_database" do
      cwd "/usr/share/doc/cacti-#{node['cacti']['version']}"
      command "mysql -u root -p#{node['mysql']['server_root_password']} #{cacti_database_info['name']} < cacti.sql"
      action :nothing
    end
  elsif platform?("ubuntu")
    execute "setup_cacti_database" do
      cwd "/usr/share/doc/cacti"
      command "zcat cacti.sql.gz | mysql -u root -p#{node['mysql']['server_root_password']} #{cacti_database_info['name']}"
      action :nothing
    end
  end

  # See this MySQL bug: http://bugs.mysql.com/bug.php?id=31061
  mysql_database_user "" do
    connection database_connection
    host "localhost"
    action :drop
  end
  
  mysql_database_user cacti_database_info['user'] do
    connection database_connection
    host "%"
    password cacti_database_info['password']
    database_name cacti_database_info['name']
    action [:create, :grant]
  end

  # Configure base Cacti settings in database
  mysql_database "configure_cacti_database_settings" do
    connection database_connection
    database_name cacti_database_info['name']
    sql <<-SQL
      INSERT INTO `settings` (`name`,`value`) VALUES ("path_rrdtool","/usr/bin/rrdtool") ON DUPLICATE KEY UPDATE `value`="/usr/bin/rrdtool";
      INSERT INTO `settings` (`name`,`value`) VALUES ("path_php_binary","/usr/bin/php") ON DUPLICATE KEY UPDATE `value`="/usr/bin/php";
      INSERT INTO `settings` (`name`,`value`) VALUES ("path_snmpwalk","/usr/bin/snmpwalk") ON DUPLICATE KEY UPDATE `value`="/usr/bin/snmpwalk";
      INSERT INTO `settings` (`name`,`value`) VALUES ("path_snmpget","/usr/bin/snmpget") ON DUPLICATE KEY UPDATE `value`="/usr/bin/snmpget";
      INSERT INTO `settings` (`name`,`value`) VALUES ("path_snmpbulkwalk","/usr/bin/snmpbulkwalk") ON DUPLICATE KEY UPDATE `value`="/usr/bin/snmpbulkwalk";
      INSERT INTO `settings` (`name`,`value`) VALUES ("path_snmpgetnext","/usr/bin/snmpgetnext") ON DUPLICATE KEY UPDATE `value`="/usr/bin/snmpgetnext";
      INSERT INTO `settings` (`name`,`value`) VALUES ("path_cactilog","#{node['cacti']['log_dir']}/cacti.log") ON DUPLICATE KEY UPDATE `value`="#{node['cacti']['log_dir']}/cacti.log";
      INSERT INTO `settings` (`name`,`value`) VALUES ("snmp_version","net-snmp") ON DUPLICATE KEY UPDATE `value`="net-snmp";
      INSERT INTO `settings` (`name`,`value`) VALUES ("rrdtool_version","rrd-1.3.x") ON DUPLICATE KEY UPDATE `value`="rrd-1.3.x";
      INSERT INTO `settings` (`name`,`value`) VALUES ("path_webroot","#{node['cacti']['webroot']}") ON DUPLICATE KEY UPDATE `value`="#{node['cacti']['webroot']}";
      UPDATE `user_auth` SET `password`=md5('#{cacti_admin_info['password']}'), `must_change_password`="" WHERE `username`='admin';
      UPDATE `version` SET `cacti`="#{node['cacti']['version']}";
    SQL
    action :query
  end
end

template "#{node['apache']['dir']}/conf.d/cacti.conf" do
  source "cacti.conf.erb"
  owner "root"
  group "root"
  mode 00644
  variables ({ :cacti_docroot => node['cacti']['webroot'] })
  notifies :reload, "service[apache2]", :delayed
end

web_app "cacti" do
  docroot node['cacti']['apache2']['docroot']
  server_name node['cacti']['apache2']['server_name']
  server_aliases node['cacti']['apache2']['server_aliases']
  ssl_certificate_file node['cacti']['apache2']['ssl']['certificate_file']
  ssl_chain_file node['cacti']['apache2']['ssl']['chain_file']
  ssl_key_file node['cacti']['apache2']['ssl']['key_file']
end

cron_d "cacti" do
  minute "*/5"
  command "/usr/bin/php #{node['cacti']['webroot']}/poller.php > /dev/null 2>&1"
  user "cacti"
end
