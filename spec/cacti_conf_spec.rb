#!/usr/bin/env ruby
require 'erubis'
require 'json'
require_relative 'spec_helper'


describe "Rendered cacti.conf apache config" do

  let(:node) { { 'fqdn' => 'unit-tester-01', 'cacti' => { 'webroot' => nil } } }

  def rendered_output
    cacti_conf_template_file = File.join( File.dirname(__FILE__), '..', 'templates', 'default', 'cacti.conf.erb')
    input = File.open(cacti_conf_template_file, 'r').read
    eruby = Erubis::Eruby.new(input)

    output = eruby.result(binding())
  end

  
  { 'ubuntu' => '/usr/share/cacti/site', 'redhat' => '/usr/share/cacti'}.each do |platform, cacti_siteroot|
    context "when on #{platform}" do
      it "should have correct site root directory" do
        node['cacti']['webroot'] = cacti_siteroot

        rendered_output.split("\n").grep(/<Directory /).each do |line|
          line.should match(Regexp.compile(cacti_siteroot))
        end
      end
    end
  end

end
