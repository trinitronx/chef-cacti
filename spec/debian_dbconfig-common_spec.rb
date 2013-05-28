#!/usr/bin/env ruby
require 'erubis'
require 'json'


describe "Debian dbconfig-common template file" do

  let(:basic_config) {
    basic_config = { "id" => "server",
                  "development" => {
                    "admin" => {
                      "password" => "rpZ!2sbSxmQP8ne9"
                    },
                    "database" => {
                      "host" => nil,
                      "name" => nil,
                      "user" => nil,
                      "password" => "IqVVhw96e7Pf"
                    }
                  }
                }
  }

  def expected_output
    expected_output_file = 'spec/resources/cacti_dbconfig-common.conf.dist'
    
    File.open(expected_output_file).read
  end

  def rendered_output
    input = File.open('templates/default/cacti_dbconfig-common.conf.erb', 'r').read
    eruby = Erubis::Eruby.new(input)

    output = eruby.result(binding())
  end

    it "should reflect the data bag attributes we provide" do
        cacti_config = JSON.load(File.open('spec/resources/data_bags/cacti/server.json', 'r'))

        @database = cacti_config['development']['database']

        rendered_output.should eq expected_output
    end

    context "when given config data" do

      { "output defaults" => nil, 
        "configure database username" => ['user', 'mycustomdbuser', 'dbc_dbuser'],
        "configure database host" => ['host', 'mycustomdbhost', 'dbc_dbserver'],
        "configure database port" => ['port', 3307, 'dbc_dbport'],
        "configure database name" => ['name', 'mycustomdbname', 'dbc_dbname'],
        "configure database password" => ['password', 'mycustomdbpass', 'dbc_dbpass']
        }.each do |do_this, inputs|
        
        it "should #{do_this} when given #{inputs.nil? ? 'nil' : inputs[0]}" do

            @database = basic_config['development']['database']

            @database[inputs[0]] = inputs[1] unless inputs.nil?

            # Expect default output template with basic config input,
            # else, check that output contains the dbc_* variable we set
            if inputs.nil?
              rendered_output.should eq expected_output
            else
              rendered_output.should include("#{inputs[2]}='#{inputs[1]}'")
            end
        end
      end
    end

end
