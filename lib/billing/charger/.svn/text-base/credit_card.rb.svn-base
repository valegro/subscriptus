module Billing

  module Charger

    module CreditCard

      def self.charge(subscription)
        amount = subscription.amount_in_cents
        # The eway in test development mode doesnt allow you charge
        # cents, only whole numbers.
        amount = (subscription.amount.to_i * 100) if RAILS_ENV == 'development'

        ApplicationError.catch! :error => ApplicationError::PAYMENT_GATEWAY do

          message = <<-MESSAGE
Thank you for using NetFox Online. Please find below the invoice for your subscription. Your NetFox Online account is http://#{subscription.account.handle}.netfoxonline.com

Please note NetFox Online charges will appear as Boxen Systems (NetFox's parent company) on your credit card statement.

We have charged the card #{subscription.card_number} that expires on #{subscription.card_expiration}.
          MESSAGE

          # Create an invoice
          invoice = subscription.invoices.create!({
            :amount => subscription.amount, 
            :amount_due => subscription.amount, 
            :increase_renewal_by => subscription.renewal_period,
            :message => message
          })

          # Attempt to purchase.
          if amount == 0 || (gateway_response = Billing::Gateway.purchase(amount, subscription.gateway_token)).success?
            # Pay and send the invoice.
            invoice.pay!
            invoice.send_invoice!

            # Create a transaction log.
            subscription.payments.create!(:amount => amount, :transaction_id => gateway_response.authorization, :success => true, :subscription_invoice_id => invoice.id) unless amount == 0
            return true
            
          else

            # If the account is in trial state, lets ignore all this
            # stuff. We only care about it if the account is active.
            unless subscription.trial? || subscription.expired?
              # Mark the subscription as being failed (if it isnt already)
              subscription.payment_failed!

              # Create a transaction log showing a failed payment.
              subscription.payments.create!(:amount => amount, :success => false, :message => gateway_response.message, :subscription_invoice_id => invoice.id)
            end

            return false

          end

        end

      end

    end

  end

end
