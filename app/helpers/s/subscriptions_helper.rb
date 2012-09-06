module S::SubscriptionsHelper
  def can_be_paid_for(status)
    status == 'active' || status == 'trial' || status == 'squatter' || status == 'unsubscribed'
  end
  
  def can_be_canceled(status)
    status == 'active' || status == 'pending' || status == 'extension_pending' || status == 'trial'
  end
end
