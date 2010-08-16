gem 'httpclient' 
gem 'soap4r' 
 
require 'soap/wsdlDriver' 
require 'cm/CampaignMasterService'

module CM
  class MissingAttribute < RuntimeError; end

  class Base
    ::V1_URI = 'http://api1.campaignmaster.com.au/v1.1/CampaignMasterService.svc?wsdl'
    @@token_expires_at = nil
    @@token = nil

    def self.driver
      # TODO: Memoize this
      fact = SOAP::WSDLDriverFactory.new(::V1_URI)
      driver = fact.create_rpc_driver
      driver.generate_explicit_type = true
      driver.options['protocol.http.ssl_config.verify_callback'] = method(:validate_certificate)
      driver
    end

    def self.access_token
      if need_new_token?
        @@token = login_with_response
      else
        @@token
      end
    end

    protected
      # TODO: Validate cert properly - see example in test.rb
      def self.validate_certificate(is_ok, ctx)
        true
      end

      def self.login_with_response
        # TODO: Read from yaml or other
        client_response = driver.login(:clientID => 5032, :userName => "ddraper", :password => "netfox")
        result = LoginResponse.new(client_response.loginResult)
        @@token_expires_at = (Time.now + result.loginResult.minutesTillTokenExpires.to_i.minutes)
        @@token = result.loginResult.tokenString
      end

      def self.need_new_token?
        return true unless @@token_expires_at
        @@token_expires_at <= Time.now
      end
  end

  class Recipient < Base
    ::PRIMARY_KEY_NAME = 'EmailAddress'
    ::ATTRS = %w(created_at from_ip email id last_modified_by)

    def self.create(hash)
      cm_recipient = self.new(hash)
      driver.AddRecipient(
        :token => access_token,
        :recipientInfo => cm_recipient,
        :operationType => CmOperationType::Insert,
        :primaryKeyName => ::PRIMARY_KEY_NAME
      )
    end

    def initialize(hash)
      validate_params(hash)
      @extra_attrs = ArrayOfCmRecipientValue.new

      @cm_recipient = CmRecipient.new
      @cm_recipient.createDateTime = Time.now
      @cm_recipient.createdBy = hash[:created_by]
      @cm_recipient.createdFromIpAddress = hash[:from_ip]
      @cm_recipient.emailAddress = hash[:email]
      @cm_recipient.emailContentType = EmailContentType::HTML
      @cm_recipient.id = hash[:id]
      @cm_recipient.lastModified = Time.now
      @cm_recipient.lastModifiedBy = hash[:last_modified_by]

      @cm_recipient.isVerified = hash.has_key?(:verified) ? hash[:verified] : true
      @cm_recipient.isActive = hash.has_key?(:active) ? hash[:active] : true
    end

    def add_field(name, value)
      field = CmRecipientValue.new
      field.fieldName = name
      field.value = value
      @extra_attrs << field
      @cm_recipient.values = @extra_attrs
    end

    protected
      def validate_params(hash)
        ::ATTRS.each do |key|
          unless hash.keys.include?(key.to_sym)
            raise MissingAttribute, key
          end
        end
      end
  end
end
