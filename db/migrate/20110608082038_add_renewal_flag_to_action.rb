class AddRenewalFlagToAction < ActiveRecord::Migration
  def self.up
    add_column :subscription_actions, :renewal, :boolean, :default => false
  end

  def self.down
    remove_column :subscription_actions, :renewal
  end
end
