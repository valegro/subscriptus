class CreateSubscriptionGifts < ActiveRecord::Migration
  def self.up
    create_table :subscription_gifts do |t|
      t.references :subscription, :gift
      t.timestamps
    end
  end

  def self.down
    drop_table :subscription_gifts
  end
end
