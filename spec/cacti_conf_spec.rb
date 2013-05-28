#!/usr/bin/env ruby
require 'erubis'
require 'json'


describe "Rendered cacti.conf apache config" do

  let(:node) { { 'fqdn' => 'unit-tester-01' } }

  def rendered_output
    input = File.open('templates/default/cacti.conf.erb', 'r').read
    eruby = Erubis::Eruby.new(input)

    output = eruby.result(binding())
  end

  @cacti_docroot = nil
  { 'ubuntu' => '/usr/share/cacti/site', 'redhat' => '/usr/share/cacti'}.each do |platform, cacti_docroot|
    context "when on #{platform}" do
      it "should have correct docroot directory" do
        @cacti_docroot = cacti_docroot

        rendered_output.split("\n").grep(/<Directory /).each do |line|
          line.should match(Regexp.compile(cacti_docroot))
        end
      end
    end
  end

end
