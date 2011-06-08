class SubscriptionActionObserver < ActiveRecord::Observer
  def after_apply(action)
    unless action.gifts.empty?
      Order.transaction do
        order = action.subscription.orders.create(:user => action.subscription.user)
        action.gifts.each do |gift|
          order.gifts << gift
        end
      end
    end
    # Invoice
    if action.subscription && action.payment
      begin
        SubscriptionMailer.deliver_activation(action.subscription)
      rescue
        notify_hoptoad($!)
      end
    end
  end
end
