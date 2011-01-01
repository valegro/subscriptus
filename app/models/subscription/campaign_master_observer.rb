class Subscription::CampaignMasterObserver < ActiveRecord::Observer
  observe :subscription

  def after_save(subscription)
    subscription.send_later :sync_to_campaign_master
  end
end
