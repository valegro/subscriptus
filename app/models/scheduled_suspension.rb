class ScheduledSuspension < ActiveRecord::Base
  belongs_to :subscription

  validates_presence_of :start_date, :duration, :state
  validates_numericality_of :duration
  validate :no_overlap

  named_scope :for_subscription, lambda { |subscription_id| { :conditions => ['subscription_id = ?', subscription_id] } }

  has_states :queued, :active, :complete, :init => :queued do
    on :activate do
      transition :queued => :active
    end

    on :deactivate do
      transition :active => :complete
    end
  end

  def no_overlap
    found = false
    self.class.for_subscription(subscription_id).each do |ss|
      if overlaps?(ss)
        found = true
      end
    end
    if found
      errors.add_to_base("Cannot overlap existing scheduled suspension for same subscription")
    end
  end

  def self.process!
    suspensions = queued.select { |ss|
      ss.start_date <= Date.today && ss.end_date > Date.today
    }
    unsuspensions = active.select { |ss|
      ss.end_date <= Date.today
    }

    queued.each do |ss|
      ss.activate!
      #ss.subscription.suspend!(ss.duration) if !ss.subscription.suspended?
      #ss.update_attribute(:active, true)
    end

    active.each do |ss|
      ss.complete!
      #ss.subscription.unsuspend! if ss.subscription.suspended?
      #ss.update_attribute(:active, false)
    end

    nil
  end

  def end_date
    start_date + duration
  end

  def overlaps?(ss)
    id != ss.id &&
      subscription_id == ss.subscription_id &&
      ((ss.start_date >= start_date && ss.start_date <= end_date) || (start_date >= ss.start_date && start_date <= ss.end_date))
  end
end
