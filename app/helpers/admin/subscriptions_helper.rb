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
        "No Change (#{subscription.state.capitalize})"
      end
    end
  end
end
