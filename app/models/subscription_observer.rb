
require 'state_callbacks'

class SubscriptionObserver < ActiveRecord::Observer
  extend StateCallbacks 
  observe_state :state
  
  on(:squatter, :active, :when => :before) do |subscription|
    subscription.state_expires_at = subscription.expires_at
  end

  on(:trial, :active, :when => :before) do |subscription|
    subscription.state_expires_at = subscription.expires_at
  end

  on(:pending, :active, :when => :before) do |subscription|
    subscription.state_expires_at = subscription.expires_at
  end

  on(:renewal_pending, :active, :when => :before) do |subscription|
    subscription.pending = nil
  end

  on(:renewal_pending, :pending, :when => :before) do |subscription|
    subscription.state_expires_at = nil
  end

  on(:trial, :squatter, :when => :before) do |subscription|
    subscription.state_expires_at = nil
  end

  on(:active, :squatter, :when => :before) do |subscription|
    subscription.state_expires_at = nil
  end
  
  on(:suspended, :active, :when => :before) do |subscription|
    subscription.state_expires_at = subscription.expires_at = subscription.expires_at.advance(:days => -1 * subscription.state_expiry_period_in_days)
  end
  
  def after_save(subscription)
    # This is copied from StateCallbacks 
    # overriding a method like after_save in a module that isn't immediately obvious to other 
    # devs using the callbacks is risky.
    state_changes = subscription.changes['#{state_name}']
    from, to = state_changes.try(:first), state_changes.try(:last)
    self.class.state_change_callback(from, to, subscription)
    
    if subscription.state_changed?
      if user = subscription.try(:user)
        Rails.logger.info "Scheduling wordpress sync for user: #{user.inspect}"
        user.delay.sync_to_wordpress
        # user.sync_to_wordpress
      end
    end
  end
end
