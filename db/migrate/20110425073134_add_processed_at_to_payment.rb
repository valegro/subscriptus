class AddProcessedAtToPayment < ActiveRecord::Migration
  def self.up
    add_column :payments, :processed_at, :timestamp
  end

  def self.down
    remove_column :payments, :processed_at
  end
end
