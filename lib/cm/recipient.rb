gem 'httpclient' 
gem 'soap4r' 
gem 'mechanize'

require 'soap/wsdlDriver' 
require 'cm/CampaignMasterService'

module CM
  class MissingAttribute < RuntimeError; end

  class Base
    V1_URI = 'http://api1.campaignmaster.com.au/v1.1/CampaignMasterService.svc?wsdl'
    @@token_expires_at = nil
    @@token = nil
    @@static_driver = nil

    def self.driver
      return @@static_driver if @@static_driver
      fact = SOAP::WSDLDriverFactory.new(V1_URI)
      @@static_driver = fact.create_rpc_driver
      @@static_driver.generate_explicit_type = true
      @@static_driver.options['protocol.http.ssl_config.verify_callback'] = method(:validate_certificate)
      @@static_driver
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

    # you could specify operation in the form like:
    # :'email_address!=' => 'foo', or :'last_modified>=' => '2010-09-01T12:00:00.000'
    # by default, this assumes operator is '=='
    # Note :'last_modfied=>' will be interpreted as :'last_modified==' due to '=>'
    # not being a valid operator.
    def self.get_recipients(conditions)
      criteria = []
      if conditions.kind_of?(Hash)
        i = 1
        conditions.each_pair { |k,v|
          criterion = CmCriterion.new
          match = k.to_s.match(/([\w_]+)([<>=!]+)?/)
          criterion.fieldName = match[1].camelize
          criterion.operator = Operators[ ( match[2] || '==' ) ]
          criterion.operand = v

          # soap4r complains without these
          criterion.order = i
          criterion.logicalOperator = LogicalOperator::And
          criterion.leftParentheses = 1
          criterion.rightParentheses = 1

          criteria.push(criterion)
          i += 1
        }
      end
      result = driver.GetRecipients(:token => access_token, :page => 1, :criteria => criteria)
      return ServiceReturn.new(result)
    end

    Operators = { '==' => CmBooleanBinaryOperator::Equals,
                  '!=' => CmBooleanBinaryOperator::NotEqual,
                  '<' => CmBooleanBinaryOperator::LessThan,
                  '<=' =>  CmBooleanBinaryOperator::LessThanEquals,
                  '>' => CmBooleanBinaryOperator::GreaterThan,
                  '>=' => CmBooleanBinaryOperator::GreaterThanEquals
    }

    # there doesn't seem to be any "delete" method in the api...
    # this one goes through the Web UI.
    # TODO: find out if there is pagination (then modify if necessary)
    def self.delete_all_recipients
      web_ui_username = 'ddraper'
      web_ui_password = 'netfox'
      agent = Mechanize.new
      login_page = agent.get('http://www.ecm7.com/cm/public/5032/clientlogin.clsp')
      login_form = login_page.forms[0]
      login_form.send "ctl00$ctl00$ctl00$PageRoot$SiteBody$PageContent$NormalAuthenticationCtrl$txtUsername=", web_ui_username
      login_form.send "ctl00$ctl00$ctl00$PageRoot$SiteBody$PageContent$NormalAuthenticationCtrl$txtPassword=", web_ui_password
      logged_in_page = agent.submit(login_form, login_form.buttons[0])
      find_recipients_page = logged_in_page.link_with(:href => /FindRecipients.aspx/).click
      find_form = find_recipients_page.forms[0]
      find_form.add_field!( '__EVENTTARGET', 'ctl00$ctl00$ctl00$PageRoot$SiteBody$PageContent$btnSearch')
      find_form.add_field!( '__EVENTARGUMENT', '')
      find_result = find_form.submit
      delete_form = find_result.forms[0]
      delete_form.checkboxes.each(&:click)
      delete_form.add_field!( '__EVENTTARGET', 'ctl00$ctl00$ctl00$PageRoot$SiteBody$PageContent$ctrlRecipientList$btnDelete')
      delete_form.add_field!( '__EVENTARGUMENT', '')
      delete_result = agent.submit(delete_form)
    end

  end

  class ServiceReturn < Hash
    def success?
      self[:status] != 'Failure'
    end

    def initialize(result)
      # TODO: use inheritance to avoid if statement?
      if result.respond_to?(:addRecipientResult)
        self[:status] = result.addRecipientResult.callStatus
        self[:message] = result.addRecipientResult.message
      elsif result.respond_to?(:getRecipientsResult) && !result.getRecipientsResult.recipients.blank?
        self[:status] = 'Unknown' # XXX do we need to return status?
        # XXX: cmRecipient is single obj or array?
        recipients = [result.getRecipientsResult.recipients.cmRecipient].flatten
        self[:recipients] = recipients.map { |rcp|
          self.class.hash_from_cm_recipient(rcp)
        }
      end
      self
    end

    def self.hash_from_cm_recipient(rcp)
      rcp_hash = Hash.new
      # XXX: do we need Id?
      rcp_hash[:id] = rcp.__xmlele.find { |ele| ele[0].name == 'Id' }.try(:[], 1)
      rcp_hash[:last_modified] = rcp.lastModified
      rcp_hash[:last_modified_by] = rcp.lastModifiedBy
      rcp_hash[:email_content_type] = rcp.emailContentType
      rcp_hash[:email_address] = rcp.emailAddress
      rcp_hash[:created_by] = rcp.createdBy
      rcp_hash[:create_date_time] = rcp.createDateTime
      rcp_hash[:created_from_ip_address] = rcp.createdFromIpAddress
      rcp_hash[:is_active] = rcp.isActive
      rcp_hash[:is_verified] = rcp.isVerified
      rcp_hash[:fields] = rcp.values
      rcp_hash
    end
  end

  class Recipient
    PRIMARY_KEY_NAME = 'EmailAddress'
    # These 3 fields are server-generated: from_ip id last_modified_by
    ATTRS = %w(created_at email)

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

    def self.find_all(hash)
      result = Proxy.get_recipients(hash)
      return result
    end

    def initialize(hash)
      validate_params(hash)
      @extra_attrs = ArrayOfCmRecipientValue.new

      @cm_recipient = CmRecipient.new
      @cm_recipient.createDateTime = Time.now
      @cm_recipient.createdBy = hash[:created_by]
      @cm_recipient.emailAddress = hash[:email]
      @cm_recipient.emailContentType = EmailContentType::HTML
      @cm_recipient.lastModified = Time.now

      @cm_recipient.isVerified = hash.has_key?(:verified) ? hash[:verified] : true
      @cm_recipient.isActive = hash.has_key?(:active) ? hash[:active] : true

      # id, createdFromIpAddress, lastModifiedBy are server-generated
      # so uncommenting the below won't do anything useful.
      # @cm_recipient.createdFromIpAddress = hash[:from_ip]
      # @cm_recipient.id = hash[:id]
      # @cm_recipient.lastModifiedBy = hash[:last_modified_by]

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
        ATTRS.each do |key|
          unless hash.keys.include?(key.to_sym)
            raise MissingAttribute, key
          end
        end
      end
  end
end
