module ChefSpecHelpers
    def setup_chefspec

        ## Lots of crappy boilerplate stuff we need to do for chefspec to work with (encrypted) data bags
        Chef::Config[:data_bag_path] = File.join(File.dirname(__FILE__), '../../test/fixtures/data_bags')
        Chef::Config[:data_bag_path] = File.join(File.dirname(__FILE__), '../../test/fixtures/data_bags')
        Chef::Config[:solo] = true
        Chef::Config[:encrypted_data_bag_secret] = File.join(File.dirname(__FILE__), '../../test/fixtures/', 'encrypted_data_bag_secret' )
        Chef::Config[:encrypted_data_bag_secret] = File.join(File.dirname(__FILE__), '../../test/fixtures/', 'encrypted_data_bag_secret' )
    end
    def create_chefspec_runner
        setup_chefspec
        # puts "INSIDE #{__FILE__}: #{COOKBOOK_PATH}"
        chef_run = ChefSpec::ChefRunner.new({ :cookbook_path => COOKBOOK_PATH })
    end
end

module ChefSpecStubHelpers
    def stub_data_bag(args, retval)
        Chef::Recipe.any_instance.stub(:data_bag_item).and_return(Hash.new)
        if args.is_a? Array
            Chef::Recipe.any_instance.stub(:data_bag_item).with(*args).and_return(retval) # Call with asterisk to pass args array as separate args to '#with'
        else
            Chef::Recipe.any_instance.stub(:data_bag_item).with(args).and_return(retval)
        end
    end

    def stub_environment(name)
        # Create a new environment (you could also use a different :let block or :before block)
        env = Chef::Environment.new
        env.name name

        # Stub any instance of Chef::Node to return this environment
        Chef::Node.any_instance.stub(:chef_environment).and_return env.name

        # Stub any calls to Environment.load to return this environment
        Chef::Environment.stub(:load).and_return env
    end
end

class String
  def strip_heredoc
    indent = scan(/^[ \t]*(?=\S)/).min.try(:size) || 0
    gsub(/^[ \t]{#{indent}}/, '')
  end
end

# Just a simple printf helper method
def debug_output(name, value)
    format_str = "%-24s: %s\n"
    printf format_str, name, value
end

# Make ChefSpecHelpers available within all 'describe' blocks
# Make ChefSpecStubHelpers available within all 'it' blocks
# https://www.relishapp.com/rspec/rspec-core/docs/helper-methods/define-helper-methods-in-a-module
RSpec.configure do |c|
    c.extend ChefSpecHelpers
    c.include ChefSpecStubHelpers
    c.include ChefSpecHelpers # allow use of create_chefspec_runner in 'let' block
end
