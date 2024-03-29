class CreateOffers < ActiveRecord::Migration
  def self.up
    create_table :offers do |t|
      t.references :publication      
      t.string :name
      t.timestamp :expires
      t.boolean :auto_renews
      t.timestamps
    end
  end

  def self.down
    drop_table :offers
  end
end
