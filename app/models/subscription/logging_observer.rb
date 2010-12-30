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
    end
    if subscription.expires_at_changed?
      attributes[:description] = "Expiry Date set to #{subscription.changes['expires_at'].last.strftime("%d/%m/%y")}"
    end
    subscription.log_entries.create(attributes) unless attributes.empty?
  end
end
