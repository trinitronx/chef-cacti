
describe 'cacti::server' do
  let(:chef_run) { ChefSpec::ChefRunner.new }

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
