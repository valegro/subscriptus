class AddConcessionToOfferTerms < ActiveRecord::Migration
  def self.up
    add_column :offer_terms, :concession, :boolean, :default => false
    OfferTerm.update_all "concession = false"
  end

  def self.down
    remove_column :offer_terms, :concession
  end
end
