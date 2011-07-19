
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

  on(:trial, :squatter, :when => :before) do |subscription|
    subscription.state_expires_at = nil
  end

  on(:active, :squatter, :when => :before) do |subscription|
    subscription.state_expires_at = nil
  end
  
  def after_save(subscription)
    if subscription.state_changed?
      if user = subscription.try(:user)
        user.delay.sync_to_wordpress
        # user.sync_to_wordpress
      end
    end
  end
end
