class Subscription::MailerObserver < ActiveRecord::Observer
  observe :subscription

  def after_enter_trial(subscription)
    SubscriptionMailer.send_later(:deliver_new_trial, subscription)
  end

  def after_enter_active(subscription)
    # send email to the user with their full subscription details
    SubscriptionMailer.send_later(:deliver_activation, subscription)
  end

  def after_enter_canceled(subscription)
    # send email to the user with their full subscription details
    SubscriptionMailer.send_later(:deliver_cancelation, subscription)
  end
end
