class CreateSubscriptionInvoices < ActiveRecord::Migration
  def self.up
    create_table :subscription_invoices do |t|
      t.integer :subscription_id
      t.float :amount
      t.float :amount_due
      t.string :invoice_number
      t.integer :harvest_invoice_id
      t.string :state
      t.date :state_updated_at
      t.timestamps
    end
    add_column :subscription_payments, :subscription_invoice_id, :integer
  end

  def self.down
    drop_table :subscription_invoices
    remove_column :subscription_payments, :subscription_invoice_id
  end
end
