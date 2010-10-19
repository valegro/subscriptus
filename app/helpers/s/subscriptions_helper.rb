module S::SubscriptionsHelper
  def can_be_paid_for(status)
    status == 'active' || status == 'trial' || status == 'squatter'
  end
end
