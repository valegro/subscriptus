class CreatePayments < ActiveRecord::Migration
  def self.up
    create_table :payments do |t|
      t.string :card_number, :first_name, :last_name
      t.timestamp :card_expiry_date
      t.decimal :amount
      t.references :subscription
      t.timestamps
    end
  end

  def self.down
    drop_table :payments
  end
end
