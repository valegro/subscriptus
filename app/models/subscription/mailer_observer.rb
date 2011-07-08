require 'state_callbacks'

class Subscription::MailerObserver < ActiveRecord::Observer
  extend StateCallbacks 
  observe :subscription
  observe_state :state

  on(:suspended, :active, :when => :before) do |subscription|
    send_email(:deliver_unsuspended, subscription)
  end

  on(:pending, :squatter) do |subscription|
    send_email(:deliver_cancelation, subscription)
  end

  on(:active, :suspended) do |subscription|
    send_email(:deliver_suspended, subscription)
  end

  on(:pending, :squatter) do |subscription|
    send_email(:deliver_pending_expired, subscription)
  end

  on(:pending, :active) do |subscription|
    send_email(:deliver_verified, subscription)
  end

  on(:active, :pending) do |subscription|
    send_email("deliver_pending_#{subscription.pending}".to_sym, subscription)
  end

  on(:trial, :pending) do |subscription|
    send_email("deliver_pending_#{subscription.pending}".to_sym, subscription)
  end

  on(:squatter, :pending) do |subscription|
    send_email("deliver_pending_#{subscription.pending}".to_sym, subscription)
  end

  def after_create(subscription)
    case subscription.state
      when 'pending'
        send_email("deliver_pending_#{subscription.pending}".to_sym, subscription)
    end
  end
  
  private
  def self.send_email(method, subscription)
    SubscriptionMailer.with_template(subscription.template_name).delay.send(method, subscription)
  end
  
  def send_email(method, subscription)
    Subscription::MailerObserver.send_email(method,subscription)
  end
end
