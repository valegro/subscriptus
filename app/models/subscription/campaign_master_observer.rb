class Subscription::CampaignMasterObserver < ActiveRecord::Observer
  observe :subscription

  def after_save(subscription)
    # TODO: I have asked campaign master to change the primary to subscription_id in their DB
    # This way, we can have one record in CM per subscription and this whole sync process will be MUCH easier
    # Will need to refactor this code and Subscriber::sync_to_campaign_master once this has been done
    #subscription.send_later :sync_to_campaign_master
  end
end
