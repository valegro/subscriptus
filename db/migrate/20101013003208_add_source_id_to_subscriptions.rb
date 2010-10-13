class AddSourceIdToSubscriptions < ActiveRecord::Migration
  def self.up
    add_column :subscriptions, :source_id, :integer
  end

  def self.down
    remove_column :subscriptions, :source_id
  end
end
