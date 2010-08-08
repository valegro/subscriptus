class Publication < ActiveRecord::Base
  has_many :subscriptions
  has_many :offers
  has_many :subscription_log_entries
end
