module Admin::OrdersHelper
  def order_event_links(order)
    order.allowed_events_for(:state).map do |event|
      link_to(event.capitalize, send("#{event}_admin_order_path", order), :confirm => "Are you sure you want to #{event} this order?")
    end
  end
end
