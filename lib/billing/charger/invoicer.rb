module Billing

  module Charger

    module Invoicer

      def self.charge(subscription)
        message = <<-MESSAGE
Thank you for using NetFox Online. Please find below the invoice for your subscription. Your NetFox Online account is http://#{subscription.account.handle}.netfoxonline.com

Please note the payment terms on the invoice - late payments may result in your account being disabled.
        MESSAGE

        invoice = subscription.invoices.create!({
          :amount => subscription.amount, 
          :amount_due => subscription.amount,
          :increase_renewal_by => subscription.renewal_period,
          :message => message
        })
        invoice.invoice!
      end

    end

  end

end
