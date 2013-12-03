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
config.action_mailer.logger = Logger.new("log/mail.log")

=begin
# Sendgrid
config.action_mailer.smtp_settings = {
  :address        => "192.168.0.101",
  :port           => "25",
  :authentication => :plain,
  :user_name      => 'admin@subscriptus.co',
  :password       => 'Dfkl!4',
  :domain         => 'subscriptus.co'
}
=end

config.action_mailer.smtp_settings = {
  :address        => "localhost",
  :port           => "25",
  :domain         => 'subscriptus.co'
}

ActionMailer::Base.default_url_options[:host] = "valegro.subscriptus.co"

# Enable threaded mode
# config.threadsafe!

# Setup Active Merchant for Staging Production
config.after_initialize do
 	ActiveMerchant::Billing::Base.mode = :production
    	# PayPal Gateway Settings
	::GATEWAY = ActiveMerchant::Billing::PaypalGateway.new(
    	:login => "accounts_api1.subscriptus.com.au",
    	:password => "7PMAFKXAD9XAR9ZP",
    	:signature => "AJ6OK3GoSm94We8j-ryLwKM.QHXcAHaJSjZBAz75YQ0FoDqSqjfVh9xr"
	)
end

# Setup Active Merchant for Staging Production
# config.after_initialize do
  # Secure Pay Gateway Settings
  # ::GATEWAY = ActiveMerchant::Billing::SecurePayAuExtendedGateway.new(  # the default_currency of this gateway is 'AUD'
  #  :login => 'abc0001',  # <MerchantID> input to Au securePay Gateway.
  #  :password => "abc123"
  # )
# end

#CAMPAIGNMASTER_USERNAME = ''
#CAMPAIGNMASTER_PASSWORD = ''
#CAMPAIGNMASTER_CLIENT_ID = ''

Wordpress.enabled = true
