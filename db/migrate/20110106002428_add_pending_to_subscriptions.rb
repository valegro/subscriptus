class AddPendingToSubscriptions < ActiveRecord::Migration
  def self.up
    change_table :subscriptions do |t|
      t.string :pending
    end
  end

  def self.down
    remove_column :subscriptions, :enum
  end
end
