class AddPreviousExpiryToActions < ActiveRecord::Migration
  def self.up
    add_column :subscription_actions, :old_expires_at, :timestamp
    add_column :subscription_actions, :new_expires_at, :timestamp
  end

  def self.down
    remove_column :subscription_actions, :old_expires_at
    remove_column :subscription_actions, :new_expires_at
  end
end
