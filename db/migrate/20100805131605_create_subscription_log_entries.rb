class CreateSubscriptionLogEntries < ActiveRecord::Migration
  def self.up
    create_table :subscription_log_entries do |t|
      t.references :subscription, :source
      t.string :old_state, :new_state, :description
      t.timestamps
    end
  end

  def self.down
    drop_table :subscription_log_entries
  end
end
