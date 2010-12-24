class CreateOrders < ActiveRecord::Migration
  def self.up
    create_table :orders do |t|
      t.references :user
      t.timestamps
      t.timestamp :state_updated_at
      t.string :state
    end
  end

  def self.down
    drop_table :orders
  end
end
