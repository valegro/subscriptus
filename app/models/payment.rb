require 'active_record/validations'
class Payment
  # include Validatable # validating without activerecord
  
    attr_accessor :card_verification, :card_number, :card_expires_on, :first_name, :last_name,
                  :money,   # the amount that should be paid
                  :customer_id # the unique client_id that is used as a reference for later operations(trigger and cancel recurrent profiles)

    # refer to: http://www.securepay.com.au/resources/Secure-XML-API/Integration-Guide-Periodic-and-Triggered-add-in-pg37.html#AppendixC
    enum_attr :card_type, %w(visa master american_express diners_club jcb) #, :init=>visa
    
    # For the ActiveRecord::Errors object.
    attr_accessor :errors

    def initialize(opts = {})
        # Create an Errors object, which is required by validations and to use some view methods.
        @errors = ActiveRecord::Errors.new(self)
    end
    
    # def purchase
    #     response = GATEWAY.purchase(price_in_cents, credit_card, options)
    #     response
    # rescue Exceptions::ZeroAmount
    #   raise Exceptions::ZeroAmount
    # rescue Exception
    #   raise Exceptions::PurchaseNotSuccessful
    # end

    def create_recurrent_profile
        response = GATEWAY.setup_recurrent(price_in_cents, credit_card, options)
        response
    rescue Exceptions::ZeroAmount
      raise Exceptions::ZeroAmount
    rescue Exception => e
      raise Exceptions::CreateRecurrentProfileNotSuccessful
    end

    # call an already setup profile for recurrent transactions
    # amount of money can be specified as an input parameter or set to nil so that the previously set amount is used
    def call_recurrent_profile
        response = GATEWAY.trigger_recurrent(price_in_cents, options)
        response
    rescue Exceptions::ZeroAmount
      raise Exceptions::ZeroAmount
    rescue Exception
      raise Exceptions::TriggerRecurrentProfileNotSuccessful
    end

    # remove an already setup profile for recurrent transactions
    def remove_recurrent_profile
        response = GATEWAY.cancel_recurrent(options)
        response
    rescue Exception
      raise Exceptions::RemoveRecurrentProfileNotSuccessful
    end

    private
    
    def price_in_cents
      self.money = 0 unless !self.money.nil?
      raise Exceptions::ZeroAmount unless self.money != 0
      (self.money * 100).to_i
    end

    def validate_card?
      unless credit_card.valid?
        credit_card.errors.full_messages.each do |message|
          @errors.add_to_base message
        end
      end
    end

    def options
      {
        :customer => customer_id # FIXME: generate one(no space, <= 20)
      }
    end

    def credit_card
      @credit_card ||= ActiveMerchant::Billing::CreditCard.new(
        :type => card_type,
        :number => card_number,
        :verification_value => card_verification,
        :month => (card_expires_on.month unless card_expires_on.blank?),
        :year => (card_expires_on.year unless card_expires_on.blank?),
        :first_name => first_name,
        :last_name => last_name
      )
    end
end
