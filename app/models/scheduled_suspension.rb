class ScheduledSuspension < ActiveRecord::Base
  belongs_to :subscription
  validates_presence_of :start_date, :duration

  def end_date
    start_date + duration
  end

  def complete?
    end_date < Date.today
  end
end
