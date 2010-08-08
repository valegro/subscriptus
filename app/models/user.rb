class User < ActiveRecord::Base
  has_many :audit_log_entries
  has_many :subscriptions
end
