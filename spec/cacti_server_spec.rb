require 'fauxhai'
require_relative 'spec_helper'

describe 'cacti::server' do
  before(:each) do
    Fauxhai.mock({ :platform => 'ubuntu', :version => '12.04' })
  end

  let(:chef_run) {
    # stub_data_bag ['users', 'tango'], tango_user_data_bag
    stub_environment 'development' # Lines up with our test data bag in test/fixtures/data_bags/cacti/server.json
    stub_environment 'development' # Lines up with our test data bag in test/fixtures/data_bags/cacti/server.json
    chef_run = create_chefspec_runner
    
    chef_run.node.automatic_attrs['lsb'] = {}
    chef_run.node.automatic_attrs['platform'] = 'ubuntu' # fauxhai alone did not work... wtf?!
    chef_run.node.automatic_attrs['platform_family'] = 'debian' # build-essential::default includes a recipe based on this.. ubuntu is in debian family
    chef_run.node.automatic_attrs['lsb']['codename'] = 'precise' # Again fauxhai... you fail me! (using fauxhai 1.1.1 ref: 2dd7b35d0018657f9a2c1af7dab8e7942878ac1b)
    chef_run.node.default['mysql'] = {}
    chef_run.node.default['mysql']['server_root_password'] = 'iloverandompasswordsbutthiswilldo'
    chef_run.node.default['mysql']['server_repl_password'] = 'iloverandompasswordsbutthiswilldo'
    chef_run.node.default['mysql']['server_debian_password'] = 'iloverandompasswordsbutthiswilldo'

    chef_run.converge described_recipe  #do |node| #'cacti::server'
  }

  it "includes another_recipe" do
  	chef_run.converge described_recipe
  	
    expect(chef_run).to include_recipe "apache2"
    expect(chef_run).to include_recipe "apache2::mod_php5"
    expect(chef_run).to include_recipe "apache2::mod_rewrite"
    expect(chef_run).to include_recipe "apache2::mod_ssl"
    expect(chef_run).to include_recipe "mysql::client"
    expect(chef_run).to include_recipe "mysql::server"
  end
end
