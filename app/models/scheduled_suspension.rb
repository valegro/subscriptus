class ScheduledSuspension < ActiveRecord::Base
  belongs_to :subscription

  validates_presence_of :start_date, :duration, :state
  validates_numericality_of :duration
  validate :no_overlap

  named_scope :for_subscription, lambda { |subscription_id| { :conditions => ['subscription_id = ?', subscription_id] } }
  named_scope :queued, :conditions => ['state = ?', 'queued']
  named_scope :active, :conditions => ['state = ?', 'active']
  named_scope :complete, :conditions => ['state = ?', 'complete']
  named_scope :incomplete, :conditions => ['state != ?', 'complete']

  has_states :queued, :active, :complete, :init => :queued do
    on :activate do
      transition :queued => :active
    end

    on :deactivate do
      transition [:queued, :active] => :complete
    end

    expires :active => :complete
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
    missed = incomplete.select { |ss|
      ss.end_date < Date.today
    }

    suspensions.each do |ss|
      ss.activate!
    end

    missed.each do |ss|
      ss.deactivate!
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
