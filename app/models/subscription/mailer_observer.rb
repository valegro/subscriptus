require 'state_callbacks'

class Subscription::MailerObserver < ActiveRecord::Observer
  extend StateCallbacks 
  observe :subscription
  observe_state :state

  on(:suspended, :active, :when => :before) do |subscription|
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

  on(:active, :pending) do |subscription|
    SubscriptionMailer.send_later("deliver_pending_#{subscription.pending}".to_sym, subscription)
  end

  on(:trial, :pending) do |subscription|
    SubscriptionMailer.send_later("deliver_pending_#{subscription.pending}".to_sym, subscription)
  end

  on(:squatter, :pending) do |subscription|
    SubscriptionMailer.send_later("deliver_pending_#{subscription.pending}".to_sym, subscription)
  end

  def after_create(subscription)
    case subscription.state
      when 'pending'
        SubscriptionMailer.send_later("deliver_pending_#{subscription.pending}".to_sym, subscription)
    end
  end
end
