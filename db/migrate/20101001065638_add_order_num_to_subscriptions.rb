class AddOrderNumToSubscriptions < ActiveRecord::Migration
  def self.up
    add_column :subscriptions, :order_num, :string
  end

  def self.down
    remove_column :subscriptions, :order_num
  end
end
