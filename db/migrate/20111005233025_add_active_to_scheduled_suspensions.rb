class AddActiveToScheduledSuspensions < ActiveRecord::Migration
  def self.up
    add_column :scheduled_suspensions, :active, :boolean, :null => false, :default => false
  end

  def self.down
    remove_column :scheduled_suspensions, :active
  end
end
