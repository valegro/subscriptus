class CreateSubscriptions < ActiveRecord::Migration
  def self.up
    create_table :subscriptions do |t|
      t.references :user, :offer, :publication
      t.string :state, :card_number, :card_expiration, :payment_method
      t.decimal :price
      t.boolean :auto_renew
      t.timestamp :state_updated_at
      t.timestamp :expires_at
      t.timestamps
    end

    # create the archive table
    ActsAsArchive.update Subscription
  end

  def self.down
    drop_table :subscriptions
    drop_table :archived_subscriptions
  end
end
