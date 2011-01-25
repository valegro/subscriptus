class AddStateExpiresAtToSubscription < ActiveRecord::Migration
  def self.up
    add_column :subscriptions, :state_expires_at, :datetime
  end

  def self.down
    remove_column :subscriptions, :state_expires_at
  end
end
