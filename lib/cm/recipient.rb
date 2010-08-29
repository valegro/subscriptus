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

  class Proxy < Base
    def self.add_recipient(hash, operation = CmOperationType::Insert)
      recipient = Recipient.new(hash)
      result = driver.AddRecipient(
        :token => access_token,
        :recipientInfo => recipient.info,
        :operationType => operation,
        :primaryKeyName => Recipient::PRIMARY_KEY_NAME
      )
      ServiceReturn.new(result)
    end
  end

  class ServiceReturn < Hash
    def success?
      self[:status] != 'Failure'
    end

    def initialize(result)
      self[:status] = result.addRecipientResult.callStatus
      self[:message] = result.addRecipientResult.message
    end
  end

  class Recipient
    ::PRIMARY_KEY_NAME = 'EmailAddress'
    ::ATTRS = %w(created_at from_ip email id last_modified_by)

    def self.update(hash)
      result = Proxy.add_recipient(hash, CmOperationType::Update)
      raise result[:message] unless result.success?
      true
    end

    def self.create!(hash)
      result = Proxy.add_recipient(hash)
      raise result[:message] unless result.success?
      true
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

      # Extra Fields
      if hash.has_key?(:fields)
        hash[:fields].each_pair do |key,value|
          add_field(key,value)
        end
      end
    end

    def add_field(name, value)
      field = CmRecipientValue.new
      field.fieldName = name.to_s
      field.value = value
      @extra_attrs << field
      @cm_recipient.values = @extra_attrs
    end

    def info
      @cm_recipient
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
