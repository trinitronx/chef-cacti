require_relative 'spec_helper'

describe 'cacti::server' do
  let(:chef_run) {
    # stub_data_bag ['users', 'tango'], tango_user_data_bag
    stub_environment 'development' # Lines up with our test data bag in test/fixtures/data_bags/cacti/server.json
    stub_environment 'development' # Lines up with our test data bag in test/fixtures/data_bags/cacti/server.json
    chef_run = create_chefspec_runner
    chef_run.converge described_recipe #'program_creator::default'
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
