#!/usr/bin/env ruby
require 'erubis'
require 'json'


describe "Debian dbconfig-common template file" do
    it "should reflect the data bag attributes we provide" do
        cacti_config = JSON.load(File.open('spec/resources/data_bags/cacti/server.json', 'r'))

        @database = cacti_config['development']['database']

        input = File.open('templates/default/cacti_dbconfig-common.conf.erb', 'r').read
        eruby = Erubis::Eruby.new(input)

        expected_output = File.open('spec/resources/cacti_dbconfig-common.conf.dist').read

        output = eruby.result(binding())

        output.should eq expected_output
    end

    it "should output defaults if given nil" do
        config = { "id" => "server",
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

        @database = config['development']['database']

        input = File.open('templates/default/cacti_dbconfig-common.conf.erb', 'r').read
        eruby = Erubis::Eruby.new(input)

        expected_output = File.open('spec/resources/cacti_dbconfig-common.conf.dist').read

        output = eruby.result(binding())

        output.should eq expected_output

    end
end
