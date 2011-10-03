class CreateScheduledSuspensions < ActiveRecord::Migration
  def self.up
    create_table :scheduled_suspensions do |t|
      t.date :start_date
      t.integer :duration
      t.integer :subscription_id

      t.timestamps
    end
  end

  def self.down
    drop_table :scheduled_suspensions
  end
end
