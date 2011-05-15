class SubscriptionLogEntry < ActiveRecord::Base
  belongs_to :publication
  belongs_to :subscription
  belongs_to :source

  named_scope :recent, lambda { {:order => "created_at desc", :conditions => "updated_at > '#{5.days.ago}'" } }
end
