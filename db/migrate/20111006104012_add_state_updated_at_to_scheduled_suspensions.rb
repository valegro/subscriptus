class AddStateUpdatedAtToScheduledSuspensions < ActiveRecord::Migration
  def self.up
    add_column :scheduled_suspensions, :state_updated_at, :datetime
    add_column :scheduled_suspensions, :state_expires_at, :datetime
  end

  def self.down
    remove_column :scheduled_suspensions, :state_updated_at
    remove_column :scheduled_suspensions, :state_expires_at
  end
end
