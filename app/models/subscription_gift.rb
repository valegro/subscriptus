class SubscriptionGift < ActiveRecord::Base
  belongs_to :subscription
  belongs_to :gift
end
