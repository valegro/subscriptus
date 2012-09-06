module Admin::OrdersHelper
  def order_event_links(order, remote = false, params={})
    order.allowed_events_for(:state).map do |event|
      if remote
        link_to_remote(event.capitalize, :url => send("#{event}_admin_order_path", order, params), :confirm => "Are you sure you want to #{event} this order?")
      else
        link_to(event.capitalize, send("#{event}_admin_order_path", order, params), :confirm => "Are you sure you want to #{event} this order?")
      end
    end
  end
end
