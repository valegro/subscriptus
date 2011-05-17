class AddDefaultToOffers < ActiveRecord::Migration
  def self.up
    add_column :offers, :primary_offer, :boolean, :default => false
    Offer.update_all "primary_offer = 'false'"
  end

  def self.down
    remove_column :offers, :primary_offer
  end
end
