class CreateSubscriptionPayments < ActiveRecord::Migration
  def self.up
    create_table :subscription_payments do |t|
      t.integer :subscription_id
      t.integer :amount
      t.boolean :success
      t.string :transaction_id
      t.text :message
      t.timestamps
    end
  end

  def self.down
    drop_table :subscription_payments
  end
end
