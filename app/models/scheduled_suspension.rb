class ScheduledSuspension < ActiveRecord::Base
  belongs_to :subscription
  validates_presence_of :start_date, :duration
end
