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

  def after_enter_active(subscription)
    # send email to the user with their full subscription details
    SubscriptionMailer.deliver_activation(subscription)
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
end
