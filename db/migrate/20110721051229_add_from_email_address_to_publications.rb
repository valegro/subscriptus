class AddFromEmailAddressToPublications < ActiveRecord::Migration
  def self.up
    add_column :publications, :from_email_address, :string
  end

  def self.down
    remove_column :publications, :from_email_address
  end
end