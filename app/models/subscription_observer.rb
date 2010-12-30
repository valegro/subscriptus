class SubscriptionObserver < ActiveRecord::Observer
  def before_enter_pending(subscription)
    subscription.generate_and_set_order_number  # order_num is sent to the user as a reference number of their subscriptions
  end

  def before_enter_extension_pending(subscription)
    subscription.generate_and_set_order_number  # order_num is sent to the user as a reference number of their subscriptions
  end

  # TODO: Send Later (DJ)
  def after_enter_trial(subscription)
    SubscriptionMailer.deliver_new_trial(subscription)
  end

  def before_enter_active(subscription)
    # TODO: Set expires_at here
    # The only case this won't work is active -> active transition (perhaps we need to hack has_states again)
  end

  def after_enter_active(subscription)
    # send email to the user with their full subscription details
    SubscriptionMailer.deliver_activation(subscription)
    unless subscription.gifts.empty?
      Order.transaction do
        order = Order.create(:user => subscription.user)
        subscription.gifts.each do |gift|
          order.gifts << gift
        end
      end
    end
  end

  def after_enter_canceled(subscription)
    # send email to the user with their full subscription details
    SubscriptionMailer.deliver_cancelation(subscription)
  end

  def after_update(record)
    record.send_later :update_campaignmaster
  end

  def after_create(record)
    record.send_later :update_campaignmaster
  end

  def after_save(record)
    attributes = {}
    if record.state_changed?
      state_changes = record.changes['state']
      attributes.merge!(
        :old_state => state_changes.first,
        :new_state => state_changes.last
      )
    end
    if record.expires_at_changed?
      attributes[:description] = "Expiry Date set to #{record.changes['expires_at'].last.strftime("%d/%m/%y")}"
    end
    record.log_entries.create(attributes) unless attributes.empty?
  end
end
