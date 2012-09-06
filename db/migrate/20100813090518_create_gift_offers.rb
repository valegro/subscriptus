class CreateGiftOffers < ActiveRecord::Migration
  def self.up
    create_table :gift_offers do |t|
      t.references :offer, :gift
      t.boolean :included, :default => false
      t.timestamps
    end
  end

  def self.down
    drop_table :gift_offers
  end
end
