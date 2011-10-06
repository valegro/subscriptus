require 'state_callbacks'

class ScheduledSuspensionObserver < ActiveRecord::Observer
  extend StateCallbacks
  observe_state :state

  def after_save(scheduled_suspension)
    subscription = scheduled_suspension.subscription
    description = "Suspension scheduled for #{scheduled_suspension.duration} days starting on #{scheduled_suspension.start_date.strftime(STANDARD_DATE_FORMAT)}"
    subscription.log_entries.create({ :old_state => subscription.state, :new_state => subscription.state, :description => description })
  end

  def after_destroy(scheduled_suspension)
    subscription = scheduled_suspension.subscription
    description = "Removed scheduled suspension (for #{scheduled_suspension.duration} days starting on #{scheduled_suspension.start_date.strftime(STANDARD_DATE_FORMAT)})"
    subscription.log_entries.create({ :old_state => subscription.state, :new_state => subscription.state, :description => description })
  end

  def after_enter_active(ss)
    ss.subscription.suspend!(ss.duration) unless ss.subscription.suspended?
    ss.update_attribute(:state_expires_at, ss.end_date)
  end

end
