class ScheduledSuspension < ActiveRecord::Base
  belongs_to :subscription
  validates_presence_of :start_date, :duration
  named_scope :active, { :conditions => ['active = ?', true] }
  named_scope :inactive, { :conditions => ['active = ?', false] }

  def self.process
    suspensions = inactive.select { |ss|
      ss.start_date <= Date.today && ss.end_date > Date.today
    }
    unsuspensions = active.select { |ss|
      ss.end_date <= Date.today
    }

    suspensions.each do |ss|
      ss.subscription.suspend!(ss.duration) if !ss.subscription.suspended?
      ss.update_attribute(:active, true)
    end

    unsuspensions.each do |ss|
      ss.subscription.unsuspend! if ss.subscription.suspended?
      ss.update_attribute(:active, false)
    end

    nil
  end

  def end_date
    start_date + duration
  end

  def complete?
    end_date < Date.today
  end
end
