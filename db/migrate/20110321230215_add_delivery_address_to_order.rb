class AddDeliveryAddressToOrder < ActiveRecord::Migration
  def self.up
    change_table :orders do |t|
      t.boolean :has_delivery_address, :null => false, :default => false
      t.string :firstname, :lastname, :email, :phone_number, :address_1, :address_2, :city, :address_state, :postcode, :country
    end
  end

  def self.down
    change_table :orders do |t|
      t.remove :has_delivery_address, :firstname, :lastname, :email, :phone_number, :address_1, :address_2, :city, :address_state, :postcode, :country
    end
  end
end