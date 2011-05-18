
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

  def before_create(subscription)
    if %w(trial active).include?(subscription.state)
      subscription.state_expires_at = subscription.expires_at
    end
  end
end
