class MovePaymentToSubscriptionAction < ActiveRecord::Migration
  def self.up
    change_table :payments do |t|
      t.references :subscription_action
      t.remove :subscription_id
    end
  end

  def self.down
    change_table :payments do |t|
      t.references :subscription
      t.remove :subscription_action
    end
  end
end
