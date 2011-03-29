class AddOfferDetailsToSubscription < ActiveRecord::Migration
  def self.up
    change_table :subscriptions do |t|
      t.column :term_length, :integer
      t.column :concession, :boolean, :default => false
    end
  end

  def self.down
    change_table :subscriptions do |t|
      t.remove :term_length
      t.remove :concession
    end
  end
end
