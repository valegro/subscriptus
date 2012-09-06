class AttachGiftsToActions < ActiveRecord::Migration
  def self.up
    rename_column :subscription_gifts, :subscription_id, :subscription_action_id
  end

  def self.down
    rename_column :subscription_gifts, :subscription_action_id, :subscription_id
  end
end
