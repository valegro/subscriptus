class Subscription < ActiveRecord::Base
  belongs_to :user
  belongs_to :offer
  has_many :subscription_log_entries
  belongs_to :publication
end
