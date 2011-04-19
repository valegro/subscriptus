class Subscription::LoggingObserver < ActiveRecord::Observer
  observe :subscription

  def after_save(subscription)
    attributes = {}
    if subscription.state_changed?
      state_changes = subscription.changes['state']
      attributes.merge!(
        :old_state => state_changes.first,
        :new_state => state_changes.last
      )
      if state_changes.first == 'pending' && state_changes.last == 'active'
        if subscription.pending == :payment
          attributes[:description] = subscription.payments.last.try(:description)
        end
        if subscription.pending == :concession_verification
          attributes[:description] = "Concession: #{subscription.note}"
        end
        if subscription.pending == :student_verification
          attributes[:description] = "Student Discount: #{subscription.note}"
        end
        # Set the pending column to nil if we are no longer pending anything
        subscription.pending = nil
      end
    end
    if subscription.expires_at_changed?
      if subscription.expires_at
        attributes[:description] = "Expiry Date set to #{subscription.changes['expires_at'].last.strftime("%d/%m/%y")}"
      else
        attributes[:description] = "Expiry Date set to nil!"
      end
    end
    subscription.log_entries.create(attributes) unless attributes.empty?
  end
end
