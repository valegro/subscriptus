class CreateOrderItems < ActiveRecord::Migration
  def self.up
    create_table :order_items do |t|
      t.references :order, :gift
      t.timestamps
    end
  end

  def self.down
    drop_table :order_items
  end
end
