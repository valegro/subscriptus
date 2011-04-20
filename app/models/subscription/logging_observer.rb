class Subscription::LoggingObserver < ActiveRecord::Observer
  observe :subscription

  def after_save(subscription)
    attributes = {}
    description = []
    if subscription.state_changed?
      state_changes = subscription.changes['state']
      attributes.merge!(
        :old_state => state_changes.first,
        :new_state => state_changes.last
      )
      if state_changes.first == 'pending' && state_changes.last == 'active'
        if subscription.pending == :payment
          description << subscription.payments.last.try(:description)
        end
        if subscription.pending == :concession_verification
          description << "Concession: #{subscription.note}"
        end
        if subscription.pending == :student_verification
          description << "Student Discount: #{subscription.note}"
        end
      end
      if state_changes.first == 'pending'
        # Set the pending column to nil if we are no longer pending anything
        subscription.pending = nil
      end
    end
    if subscription.expires_at_changed?
      if subscription.expires_at
        description << "Expiry Date set to #{subscription.changes['expires_at'].last.strftime("%d/%m/%y")}"
      else
        description << "Expiry Date set to nil!"
      end
    end
    attributes[:description] = description.join("; ")
    subscription.log_entries.create(attributes) unless attributes.empty?
  end
end
