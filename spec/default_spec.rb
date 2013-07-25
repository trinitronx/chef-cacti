require_relative 'spec_helper'

describe 'cacti::default' do
  let(:chef_run) {
    # stub_data_bag ['users', 'tango'], tango_user_data_bag
    chef_run = create_chefspec_runner
    chef_run.converge described_recipe #'program_creator::default'
  }

	it 'should do nothing' do
		expect(chef_run).to be_instance_of(ChefSpec::ChefRunner)
	end

end