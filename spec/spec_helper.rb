# This file is copied to ~/spec when you run 'ruby script/generate rspec'
# from the project root directory.
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path(File.join(File.dirname(__FILE__),'..','config','environment'))
require 'spec/autorun'
require 'spec/rails'
require 'shoulda'
require 'faker'
require 'factory_girl'
require 'webmock/rspec'

require 'capybara/rails' 
require 'capybara/dsl'

WebMock.disable_net_connect!(
  :allow_localhost => true,
  :allow => 'https://api.securepay.com.au/xmlapi/payment',
  :allow => 'https://www.securepay.com.au/test/payment'
)

factories = Dir.glob('*/factories.rb') + Dir.glob('*/factories/*.rb')
factories.each { |f|
  begin
    require f
  rescue Factory::DuplicateDefinitionError
    # warn here?
  end
}

# Uncomment the next line to use webrat's matchers
#require 'webrat/integrations/rspec-rails'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories.
Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

Spec::Runner.configure do |config|
  # If you're not using ActiveRecord you should remove these
  # lines, delete config/database.yml and disable :active_record
  # in your config/boot.rb
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false
  config.fixture_path = RAILS_ROOT + '/spec/fixtures/'

  config.include(Capybara, :type => :integration)

  # == Fixtures
  #
  # You can declare fixtures for each example_group like this:
  #   describe "...." do
  #     fixtures :table_a, :table_b
  #
  # Alternatively, if you prefer to declare them only once, you can
  # do so right here. Just uncomment the next line and replace the fixture
  # names with your fixtures.
  #
  # config.global_fixtures = :table_a, :table_b
  #
  # If you declare global fixtures, be aware that they will be declared
  # for all of your examples, even those that don't use them.
  #
  # You can also declare which fixtures to use (for example fixtures for test/fixtures):
  #
  # config.fixture_path = RAILS_ROOT + '/spec/fixtures/'
  #
  # == Mock Framework
  #
  # RSpec uses its own mocking framework by default. If you prefer to
  # use mocha, flexmock or RR, uncomment the appropriate line:
  #
  config.mock_with :mocha
  # config.mock_with :flexmock
  # config.mock_with :rr
  #
  # == Notes
  #
  # For more information take a look at Spec::Runner::Configuration and Spec::Runner
end

# Fix a Mock properly
# See https://github.com/floehopper/mocha/issues/28
module Mocha
  module ParameterMatchers
    class InstanceOf
      def ==(parameter)
        parameter.instance_of?(@klass)
      end
    end
    
    class Equals
      def matches?(available_parameters)
        parameter = available_parameters.shift
        @value == parameter
      end
    end
  end
end

def login_as(user)
  controller.stubs(:current_user).returns( user )
end

def user_login
  login_as( Factory.create(:user) )
end

def admin_login
  login_as( Factory.create(:admin) )
end

def https!
  ActionController::TestRequest.any_instance.stubs(:ssl?).returns(true)
end

def stub_wordpress
  Wordpress.stubs(:exists?).returns(false)
  
  stub_request(:get, /.*crikey.*/).to_return { |request|
    case request.uri.query_values['func']
    when 'exists' then {:body => ''}
    when 'create','update' then {:body =>request.uri.query_values['login']}
    else
      {:body =>'Unknown function'}
    end
    }
end


# In odre to test Campaign Master lib, comment out below.
# WARNING:  it will erase all of your Campaign Master records.
# TODO: unmock for specs for cm lib.
# I couldn't figure out unmocking to work correctly... :(
# see http://stufftohelpyouout.blogspot.com/2009/09/how-to-unmock-in-mocha-and-temporarily.html
# or do class method aliasing (class <<self ; alias_method :original_spam, :spam ; end)
# test campaignmaster stuff separately after uncommenting these
CM::Recipient #load if not loaded
module CM
  class Recipient
    def self.create!(hash)
      return true
    end
    def self.update(hash)
      return true
    end
    def self.find_all(hash)
      return {}
    end
  end
  class Proxy
    def self.add_recipient
      return {}
    end
    def self.get_recipients
      return {}
    end
    def self.delete_all_recipients
      return nil
    end
  end
end

Wordpress.enabled = true
