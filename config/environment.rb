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
  config.autoload_paths += %W( #{RAILS_ROOT}/app/factories )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  #config.gem "aws-s3", :lib => "aws/s3"
  config.gem "activemerchant", :lib => "active_merchant", :version => "1.4.1"


  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  config.active_record.observers = :subscription_observer, :subscription_action_observer, :user_observer, "subscription/logging_observer", "subscription/mailer_observer", "subscription/campaign_master_observer", :scheduled_suspension_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de

  # This is for rendering Liquid templates. A user's state is returned as a symbol
  # and we want to put it in an email template, so we'll convert it to a string.
  Symbol.class_eval do
    def to_liquid
      to_s.upcase
    end
  end
end

# TODO: Make confir options
STANDARD_TIME_FORMAT = '%d/%m/%Y %H:%M %Z'
STANDARD_DATE_FORMAT = '%d/%m/%Y'
APP_TIMEZONE = 'Melbourne'

require 'delayed_job'
require 'also_migrate_hack'

