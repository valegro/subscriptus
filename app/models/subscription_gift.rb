class SubscriptionGift < ActiveRecord::Base
  belongs_to :subscription_action
  belongs_to :gift

  named_scope :included, :conditions => { :included => true }
  named_scope :optional, :conditions => { :included => false }
end
