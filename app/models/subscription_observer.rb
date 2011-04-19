class SubscriptionObserver < ActiveRecord::Observer

  def after_enter_pending(subscription)
    SubscriptionMailer.deliver_pending(subscription)
  end
  
  def after_exit_pending(subscription)
    case subscription.state
      when 'active' then SubscriptionMailer.deliver_verified(subscription)
      when 'squatter' then SubscriptionMailer.deliver_pending_expired(subscription)
    end
  end
end
