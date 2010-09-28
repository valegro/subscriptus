class AddRecurrentIdColumnToSubscriptions < ActiveRecord::Migration
  def self.up
    add_column :subscriptions, :recurrent_id, :string
  end

  def self.down
    remove_column :subscriptions, :recurrent_id
  end
end
