class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions do |t|
      t.references :user, :offer, :publication
      t.string :state
      t.decimal :price
      t.timestamp :state_updated_at
      t.timestamp :expires_at
      t.timestamps
    end
  end

  def self.down
    drop_table :subscriptions
  end
end
