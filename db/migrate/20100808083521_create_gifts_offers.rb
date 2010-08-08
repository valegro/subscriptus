class CreateGiftsOffers < ActiveRecord::Migration
  def self.up
    create_table :gifts_offers do |t|
      t.references :gift, :offer
    end
  end

  def self.down
    drop_table :gifts_offers
  end
end
