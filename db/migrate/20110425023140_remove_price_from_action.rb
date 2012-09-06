class RemovePriceFromAction < ActiveRecord::Migration
  def self.up
    remove_column :subscription_actions, :price
  end

  def self.down
    add_column :subscription_actions, :price, :decimal
  end
end
