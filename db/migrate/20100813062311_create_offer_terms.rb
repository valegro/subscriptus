class CreateOfferTerms < ActiveRecord::Migration
  def self.up
    create_table :offer_terms do |t|
      t.references :offer
      t.decimal :price
      t.integer :months
      t.timestamps
    end
  end

  def self.down
    drop_table :offer_terms
  end
end
