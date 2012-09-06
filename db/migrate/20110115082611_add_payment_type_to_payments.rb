class AddPaymentTypeToPayments < ActiveRecord::Migration
  def self.up
    add_column :payments, :payment_type, :string
    add_column :payments, :reference, :string
  end

  def self.down
    remove_column :payments, :payment_type
    remove_column :payments, :reference
  end
end
