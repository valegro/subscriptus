module Admin::SubscriptionsHelper
  def state_change(old, _new, subscription)
    if old
      "#{old.humanize} -> #{_new.humanize}"
    elsif _new
      "New #{_new.humanize}"
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
    links = subscription.allowed_events_for(:state).select { |event| ![ :cancel, :pay_later, :expire, :enqueue_for_renewal, :postpone, :new_trial, :suspend, :unsuspend ].include?(event.to_sym) }.map do |event|
      link_to(event.humanize, send("#{event}_admin_subscription_path", subscription), :confirm => "Are you sure you want to #{event} this subscription?")
    end
    
    links.tap do |l|
      l << case
      when subscription.active?  && subscription.expires_at
        link_to_remote 'Suspend', :url => suspend_admin_subscription_path(subscription), :method => :get
      when subscription.suspended?
        link_to 'Unsuspend', unsuspend_admin_subscription_path(subscription), :method => :post
      end
    end
  end
end
