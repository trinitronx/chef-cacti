#!/usr/bin/env rake

require 'rspec/core/rake_task'

task :default => 'test:foodcritic'

task :test => [ 'test:unit:rspec', 'test:foodcritic', 'test:knife' ]

namespace :test do

  namespace :unit do

    RSpec::Core::RakeTask.new(:rspec) do |t|
      puts Dir.pwd
      t.verbose = true
    end
  end

  desc "Runs foodcritic linter"
  task :foodcritic do
    Rake::Task["test:prepare_sandbox"].execute
  
    if Gem::Version.new("1.9.2") <= Gem::Version.new(RUBY_VERSION.dup)
      sh "foodcritic -f any #{sandbox_path}"
    else
      puts "WARN: foodcritic run is skipped as Ruby #{RUBY_VERSION} is < 1.9.2."
    end
  end
  
  desc "Runs knife cookbook test"
  task :knife do
    Rake::Task['test:prepare_sandbox'].execute
  
    sh "bundle exec knife cookbook test cookbook -c test/.chef/knife.rb -o #{sandbox_path}/../"
  end
  
  task :prepare_sandbox do
    files = %w{*.md *.rb attributes definitions libraries files providers recipes resources templates}
  
    rm_rf sandbox_path
    mkdir_p sandbox_path
    cp_r Dir.glob("{#{files.join(',')}}"), sandbox_path
  end

end


private
def sandbox_path
  File.join(File.dirname(__FILE__), %w(tmp cookbooks cookbook))
end
