module Admin::SubscriptionsHelper
  def state_change(old, _new, subscription)
    if old
      "#{old.capitalize} -> #{_new.capitalize}"
    elsif _new
      "New #{_new.capitalize}"
    else
      if subscription.active?
        "Renewal"
      else
        "No Change (#{subscription.state.humanize})"
      end
    end
  end

  def subscription_event_links(subscription)
    # Don't allow manual expiration
    subscription.allowed_events_for(:state).select { |event| ![ :cancel, :pay_later, :expire, :enqueue_for_renewal, :postpone, :new_trial ].include?(event.to_sym) }.map do |event|
      link_to(event.humanize, send("#{event}_admin_subscription_path", subscription), :confirm => "Are you sure you want to #{event} this subscription?")
    end
  end
end
