module Billing

  module Cycle

    def self.run

      # Expire states.
      Subscription.expire_states
      Subscription::Invoice.expire_states

      # Sync invoices.
      Subscription::Invoice.unpaid.find_in_batches do |group|
        group.each do |invoice|
          invoice.sync_with_harvest!
        end
      end

      # Charge the neccessary people.
      Subscription.payment_due.find_in_batches do |group|
        group.each do |subscription|
          subscription.charge
        end
      end

    end

  end

end
