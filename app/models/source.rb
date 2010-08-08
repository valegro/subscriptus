class Source < ActiveRecord::Base
  has_many :subscription_log_entries
end
