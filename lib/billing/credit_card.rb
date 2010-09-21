module Billing

  module CreditCard

    CREDIT_CARDS = [ :visa, :master ]
    CREDIT_CARDS << :bogus if RAILS_ENV == 'development'

    def self.included(klass)
      klass.send :attr_reader, :card_type, :expire_month, :expire_year
      klass.send :include, InstanceMethods
      klass.send :validate, :check_credit_card, :if => Proc.new { |record| record.credit_card? }
      klass.send :validate, :store_credit_card, :if => Proc.new { |record| record.credit_card? }

      # If we have successfully saved with a credit card, lets get rid
      # of it.
      klass.send :after_save do |record|
        record.clear_credit_card if record.credit_card?
      end

    end

    module InstanceMethods

      def card_type=(value)
        @card_type = self.credit_card.type = value.to_s
      end

      def card_number=(value)
        credit_card.number = value.kind_of?(Array) ? value.join('') : value
        write_attribute :card_number, value
      end

      def expire_month=(value)
        @expire_month = self.credit_card.month = value.to_i
      end

      def expire_year=(value)
        @expire_year = self.credit_card.year = value.to_i
      end

      def clear_credit_card
        @credit_card = nil
      end

      def credit_card
        @credit_card ||= ActiveMerchant::Billing::CreditCard.new({
          :number => self.card_number
        }.merge(self.to_credit_card))
      end

      def credit_card?
        defined?(@credit_card) && @credit_card
      end

      private

        def check_credit_card
          @credit_card_valid = true
          unless credit_card.valid?
            { :type => :card_type, :number => :card_number, :month => :expire_month, :year => :expire_year }.each_pair do |key, value|
              if credit_card.errors.has_key?(key)
                credit_card.errors[key].each { |x| self.errors.add value, x }
                @credit_card_valid = false
              end
            end
          end
        end

        def store_credit_card
          if @credit_card_valid
            gateway_response = if gateway_token.blank?
              Billing::Gateway.store(credit_card, :billing_address => to_activemerchant)
            else
              Billing::Gateway.update(gateway_token, credit_card, :billing_address => to_activemerchant)
            end
            if gateway_response.success?
              # Because eWay are silly, when the gateway is in test mode,
              # storing a credit card number returns a customer id that is
              # not allowed on the server. Here I force it to be the one
              # that works on the test gateway.
              gateway_token = Billing::Gateway.test? ? '9876543211000' : gateway_response.token
              write_attribute :gateway_token, gateway_token
              write_attribute :card_number, credit_card.display_number
              write_attribute :card_expiration, ("%02d-%d" % [credit_card.expiry_date.month, credit_card.expiry_date.year])
            else
              errors.add_to_base("Gateway: #{gateway_response.message}")
            end
          end
        end

    end

  end

end
