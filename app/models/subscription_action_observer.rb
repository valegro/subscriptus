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
      SubscriptionMailer.with_template(action.subscription.template_name).send_later(:deliver_activation, action.subscription)
    end
  end
end
