require 'state_callbacks'

class Subscription::MailerObserver < ActiveRecord::Observer
  extend StateCallbacks 
  observe :subscription

  on(:suspended, :active) do |subscription|
    SubscriptionMailer.send_later(:deliver_unsuspended, subscription)
  end

  on(:pending, :squatter) do |subscription|
    SubscriptionMailer.send_later(:deliver_cancelation, subscription)
  end

  on(:active, :squatter) do |subscription|
    SubscriptionMailer.send_later(:deliver_expired, subscription)
  end

  on(:active, :suspended) do |subscription|
    SubscriptionMailer.send_later(:deliver_suspended, subscription)
  end

  on(:pending, :squatter) do |subscription|
    SubscriptionMailer.send_later(:deliver_pending_expired, subscription)
  end

  on(:pending, :active) do |subscription|
    SubscriptionMailer.send_later(:deliver_verified, subscription)
  end

  def after_create(subscription)
    case subscription.state
      when 'trial'
        SubscriptionMailer.send_later(:deliver_new_trial, subscription)
      when 'pending'
        SubscriptionMailer.send_later("deliver_pending_#{subscription.pending}".to_sym, subscription)
    end
  end

  def after_save(subscription)
    state_changes = subscription.changes['state']
    from, to = state_changes.try(:first), state_changes.try(:last)
    self.class.state_change_callback(from, to, subscription)
  end
end
