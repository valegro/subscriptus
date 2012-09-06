class AddPendingActionToSubscriptions < ActiveRecord::Migration
  def self.up
    change_table :subscriptions do |t|
      t.references :pending_action
    end
  end

  def self.down
    change_table :subscriptions do |t|
      t.remove :pending_action_id
    end
  end
end
