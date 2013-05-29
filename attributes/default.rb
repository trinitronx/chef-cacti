#
# Cookbook Name:: cacti
# Attributes:: cacti
#
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

default['cacti']['version'] = ""

# Apache2 attributes

default['cacti']['apache2']['server_name']             = node['fqdn']
default['cacti']['apache2']['server_aliases']          = [ node['hostname'] ]

# Platform specific attributes
case platform
when "redhat", "centos", "scientific", "fedora", "suse", "amazon", "oracle"
  default['cacti']['apache2']['ssl']['certificate_file'] = "/etc/pki/tls/certs/localhost.crt"
  default['cacti']['apache2']['ssl']['chain_file']       = ""
  default['cacti']['apache2']['ssl']['force']            = false
  default['cacti']['apache2']['ssl']['key_file']         = "/etc/pki/tls/private/localhost.key"
  default['cacti']['apache2']['docroot'] = '/var/www/html'

  default['cacti']['log_dir'] = '/usr/share/cacti/log'
  default['cacti']['webroot'] = '/usr/share/cacti/'

when "debian", "ubuntu"
  default['cacti']['apache2']['ssl']['certificate_file'] = "/etc/ssl/certs/ssl-cert-snakeoil.pem"
  default['cacti']['apache2']['ssl']['chain_file']       = ""
  default['cacti']['apache2']['ssl']['force']            = false
  default['cacti']['apache2']['ssl']['key_file']         = "/etc/ssl/private/ssl-cert-snakeoil.key"
  default['cacti']['apache2']['docroot'] = '/var/www'

  default['cacti']['log_dir'] = '/var/log/cacti'
  default['cacti']['webroot'] = '/usr/share/cacti/site'

end

# Spine attributes

default['cacti']['spine']['version']  = node['cacti']['version']
default['cacti']['spine']['url']      = "http://www.cacti.net/downloads/spine/cacti-spine-#{node['cacti']['spine']['version']}.tar.gz"
default['cacti']['spine']['checksum'] = "2226070cd386a4955063a87e99df2fa861988a604a95f39bb8db2a301774b3ee"
