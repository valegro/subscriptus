class SubscriptionObserver < ActiveRecord::Observer

  def before_enter_active(subscription)
    # TODO: Set expires_at here
    # The only case this won't work is active -> active transition (perhaps we need to hack has_states again)
  end

  def after_enter_active(subscription)
    unless subscription.gifts.empty? || %w(active suspended).include?(subscription.state_was)
      Order.transaction do
        order = subscription.orders.create(:user => subscription.user)
        subscription.gifts.each do |gift|
          order.gifts << gift
        end
      end
    end
  end

end
