class ReplaceActiveWithStateInScheduledSuspensions < ActiveRecord::Migration
  class ScheduledSuspension < ActiveRecord::Base
  end

  def self.up
    ScheduledSuspension.delete_all
    remove_column :scheduled_suspensions, :active
    add_column :scheduled_suspensions, :state, :string, :null => false
  end

  def self.down
    add_column :scheduled_suspensions, :active, :boolean, :null => false, :default => false
    remove_column :scheduled_suspensions, :state
  end
end
