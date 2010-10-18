require 'active_record/validations'

class Payment
  # include Validatable # validating without activerecord
  
    attr_accessor :card_verification, :card_number, :card_expires_on, :first_name, :last_name,
                  :money, # the amount that should be paid
                  :order_num, # order_number is a unique number for each paid subscription. it is also saved in subscription table
                  :customer_id # the unique client_id that is used as a reference for later operations(trigger and cancel recurrent profiles)

    # refer to: http://www.securepay.com.au/resources/Secure-XML-API/Integration-Guide-Periodic-and-Triggered-add-in-pg37.html#AppendixC
    enum_attr :card_type, %w(visa master american_express diners_club jcb) #, :init=>visa
    
    # For the ActiveRecord::Errors object.
    attr_accessor :errors
    
    def initialize(opts = {})
        # Create an Errors object, which is required by validations and to use some view methods.
        @errors = ActiveRecord::Errors.new(self)
    end
    
    def purchase
      returning response = GATEWAY.purchase(price_in_cents, credit_card, options("recurrent")) do
        log_transactions("purchase", response)
        raise Exceptions::PurchaseNotSuccessful.new(response.message) unless response.success?
      end
    rescue Exception => e
      if e.is_a?(Exceptions::ZeroAmount)
        raise e
      else
        raise Exceptions::PurchaseNotSuccessful
      end
    end

    def create_recurrent_profile
      returning response = GATEWAY.setup_recurrent(price_in_cents, credit_card, options("recurrent")) do
        log_transactions("setup new recurrent profile", response)
        raise Exceptions::CreateRecurrentProfileNotSuccessful.new("unsuccessfull responce::" + response.message) unless response.success?
      end
    rescue Exception => e
      if e.is_a?(Exceptions::ZeroAmount)
        raise e
      else
        raise Exceptions::CreateRecurrentProfileNotSuccessful.new(e.message)
      end
    end

    # call an already setup profile for recurrent transactions
    # amount of money can be specified as an input parameter or set to nil so that the previously set amount is used
    def call_recurrent_profile
      returning response = GATEWAY.trigger_recurrent(price_in_cents, options("recurrent")) do
        log_transactions("trigger existing recurrent profile", response)
        raise Exceptions::TriggerRecurrentProfileNotSuccessful.new(response.message) unless response.success?
      end
    rescue Exception => e
      if e.is_a?(Exceptions::ZeroAmount)
        raise e
      else
        raise Exceptions::TriggerRecurrentProfileNotSuccessful.new(e.message)
      end
    end

    # remove an already setup profile for recurrent transactions
    def remove_recurrent_profile
      returning response = GATEWAY.cancel_recurrent(options("recurrent")) do
        log_transactions("remove existing recurrent profile", response)
        raise Exceptions::RemoveRecurrentProfileNotSuccessful.new(response.message) unless response.success?
      end
    rescue Exception
      if e.is_a?(Exceptions::ZeroAmount)
        raise e
      else
        raise Exceptions::RemoveRecurrentProfileNotSuccessful.new(e.message)
      end
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

    def options(action)
      case action
      when "purchase"
        option = :order_id
      when "recurrent"
        option = :customer
      end
      { option => customer_id }
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

    def log_transactions(action, response)
      t = TransactionLog.new do |t_log|
          t_log.recurrent_id = customer_id
          # t_log.user_id =
          t_log.order_num = order_num
          t_log.action = action
          t_log.money = money
          t_log.success = response.success?
          t_log.message = response.message
      end
      t.save!
    end

end