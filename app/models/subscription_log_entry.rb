class SubscriptionLogEntry < ActiveRecord::Base
  belongs_to :publication
  belongs_to :subscription
  belongs_to :source
end
