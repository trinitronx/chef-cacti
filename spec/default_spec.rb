describe 'cacti::default' do
	let(:chef_run) {
		ChefSpec::ChefRunner.new.converge(described_recipe)
	}

	it 'should do nothing' do
		expect(chef_run).to be_instance_of(ChefSpec::ChefRunner)
	end

end