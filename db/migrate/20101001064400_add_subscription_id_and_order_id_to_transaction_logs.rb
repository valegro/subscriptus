class AddSubscriptionIdAndOrderIdToTransactionLogs < ActiveRecord::Migration
  def self.up
    add_column :transaction_logs, :subscription_id, :integer
    add_column :transaction_logs, :order_num, :string
  end

  def self.down
    remove_column :transaction_logs, :order_num
    remove_column :transaction_logs, :subscription_id
  end
end
