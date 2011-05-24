# Settings specified here will take precedence over those in config/environment.rb

# In the development environment your application's code is reloaded on
# every request.  This slows down response time but is perfect for development
# since you don't have to restart the webserver when you make code changes.
config.cache_classes = false

# Log error messages when you accidentally call methods on nil.
config.whiny_nils = true

# Show full error reports and disable caching
config.action_controller.consider_all_requests_local = true
config.action_view.debug_rjs                         = true
config.action_controller.perform_caching             = false

# Don't care if the mailer can't send
config.action_mailer.raise_delivery_errors = false
ActionMailer::Base.default_url_options[:host] = "127.0.0.1:3000"

# Setup Active Merchant for development
config.after_initialize do
  # Secure Pay Gateway Settings
  ActiveMerchant::Billing::Base.mode = :test
  ::GATEWAY = ActiveMerchant::Billing::SecurePayAuExtendedGateway.new(  # the default_currency of this gateway is 'AUD'
    :login => 'CKR0030',  # <MerchantID> input to Au securePay Gateway.
    :password => "q02nnn8h",
    :test => true
  )

  # Mock Wordpress
  require 'mocha'
  Wordpress.stubs(:authenticate).returns(true)
end

CAMPAIGNMASTER_USERNAME = 'ddraper'
CAMPAIGNMASTER_PASSWORD = 'netfox'
CAMPAIGNMASTER_CLIENT_ID = '5032'

Wordpress.enabled = true
