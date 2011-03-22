# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
# RAILS_GEM_VERSION = '2.3.8' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # use rake secret to generate new secret keys
  config.action_controller.session = { :key => "_subscriptus_session", :secret => "ab2d6e75e910ab82d74be6721ee22e4bb514e1110be05748e38f93483385a5233a9cd08aed0bf3383f9dc56bf5d7973bbd46d669236c5cad7f90f48f93e6ef02" }
  
  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )
  config.load_paths += %W( #{RAILS_ROOT}/app/factories )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  #config.gem "aws-s3", :lib => "aws/s3"

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
  config.active_record.observers = :subscription_observer, :user_observer, "subscription/logging_observer", "subscription/mailer_observer", "subscription/campaign_master_observer"

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
end

# TODO: Make confir options
STANDARD_TIME_FORMAT = '%H:%M %d/%m/%y %Z'
APP_TIMEZONE = 'Melbourne'

__END__
gem 'httpclient' 
gem 'soap4r' 
gem 'mechanize'

require 'soap/wsdlDriver' 
require 'cm/CampaignMasterService'

require 'cm/recipient'

      def self.validate_certificate(is_ok, ctx)
        true
      end

puts "Calling factory in ENV"
fact = SOAP::WSDLDriverFactory.new(CM::Base::V1_URI)
puts "end calling factory in ENV"
driver = fact.create_rpc_driver
driver.generate_explicit_type = true
driver.options['protocol.http.ssl_config.verify_callback'] = method(:validate_certificate)
driver.options["protocol.http.connect_timeout"] = 60 # XXX should defaults be settable somewhere?
driver.options["protocol.http.receive_timeout"] = 60

CM::Base.driver = driver
