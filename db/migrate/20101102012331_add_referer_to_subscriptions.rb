class AddRefererToSubscriptions < ActiveRecord::Migration
  def self.up
    add_column :subscriptions, :referrer, :text
  end

  def self.down
    remove_column :subscriptions, :referrer
  end
end
