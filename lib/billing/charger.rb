module Billing

  module Charger

    CREDIT_CARD = 0
    INVOICE = 1
    PAYMENT_METHODS = [ CREDIT_CARD, INVOICE ]

    def self.included(klass)
      klass.send :named_scope, :payment_due, lambda {
        { :conditions => [ ' next_renewal_at <= ? ', Time.now.utc ] }
      }
    end

    def self.calculate_discount(renewal_period, monthly_cost)
      cost = renewal_period * monthly_cost
      discount = Subscription::RENEWAL_DISCOUNTS[renewal_period]
      return discount.try(:>, 0) ? (cost - cost * discount) : cost
    end

    def amount_in_cents
      (amount * 100).to_i
    end

    def charge!
      ApplicationError.catch! :error => ApplicationError::BILLING do
        ActiveRecord::Base.transaction do
          if payment_method == Billing::Charger::CREDIT_CARD
            Billing::Charger::CreditCard.charge self
          elsif payment_method == Billing::Charger::INVOICE
            Billing::Charger::Invoicer.charge self
          end
        end
      end
    end

    def charge
      begin
        charge!
      rescue
        false
      end
    end

    def advance_renewal_period_by(options = {})
      current_renewal_date = (next_renewal_at || Time.now)
      update_attributes(:next_renewal_at => current_renewal_date.advance(options))
    end

  end

end
