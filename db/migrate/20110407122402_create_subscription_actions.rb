class CreateSubscriptionActions < ActiveRecord::Migration
  def self.up
    create_table :subscription_actions do |t|
      t.string :offer_name
      t.decimal :price
      t.integer :term_length
      t.references :source, :subscription
      t.timestamp :applied_at
      t.timestamps
    end
  end

  def self.down
    drop_table :subscription_actions
  end
end
