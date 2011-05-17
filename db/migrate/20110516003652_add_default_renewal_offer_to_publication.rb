class AddDefaultRenewalOfferToPublication < ActiveRecord::Migration
  def self.up
    add_column :publications, :default_renewal_offer_id, :integer
  end

  def self.down
    remove_column :publications, :default_renewal_offer_id
  end
end
