class Subscription::CampaignMasterObserver < ActiveRecord::Observer
  observe :subscription

  # def after_save(subscription)
  #   subscription.delay.sync_to_campaign_master
  # end

  # TODO: Putting this here instead of in subscription_observer because right now state_callbacks does not allow
  # us to define a before_save or after_save as well as 'on' methods
  #def before_save(subscription)
    # Ensure state expiry is set
  #  if %w(trial active).include?(subscription.state)
  #    subscription.state_expires_at = subscription.expires_at
  #  end
  # end
end
