# Settings specified here will take precedence over those in config/environment.rb

# The production environment is meant for finished, "live" apps.
# Code is not reloaded between requests
config.cache_classes = true

# Full error reports are disabled and caching is turned on
config.action_controller.consider_all_requests_local = false
config.action_controller.perform_caching             = true
config.action_view.cache_template_loading            = true

# See everything in the log (default is :info)
# config.log_level = :debug

# Use a different logger for distributed setups
# config.logger = SyslogLogger.new

# Use a different cache store in production
# config.cache_store = :mem_cache_store

# Enable serving of images, stylesheets, and javascripts from an asset server
# config.action_controller.asset_host = "http://assets.example.com"

# ActionMailer Settings for Heroku
config.action_mailer.delivery_method = :smtp
config.action_mailer.perform_deliveries = true
config.action_mailer.raise_delivery_errors = true
config.action_mailer.default_charset = "utf-8"

# NetFox Sendgrid (for now)
config.action_mailer.smtp_settings = {
  :address        => "smtp.sendgrid.net",
  :port           => "25",
  :authentication => :plain,
  :user_name      => 'daniel@netfox.com',
  :password       => '12qwaszx',
  :domain         => 'crikey.com.au'
}

ActionMailer::Base.default_url_options[:host] = "subscribe.crikey.com.au"

# Enable threaded mode
# config.threadsafe!

# Setup Active Merchant for Staging Production
config.after_initialize do
  # Secure Pay Gateway Settings
  ::GATEWAY = ActiveMerchant::Billing::SecurePayAuExtendedGateway.new(  # the default_currency of this gateway is 'AUD'
    :login => 'CKR00',  # <MerchantID> input to Au securePay Gateway.
    :password => "q02nnn8h"
  )
end

CAMPAIGNMASTER_USERNAME = 'ddraper'
CAMPAIGNMASTER_PASSWORD = 'netfox'
CAMPAIGNMASTER_CLIENT_ID = '5032'

Wordpress.enabled = true
