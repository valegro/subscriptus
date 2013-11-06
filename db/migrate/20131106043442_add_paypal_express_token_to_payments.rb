class AddPaypalExpressTokenToPayments < ActiveRecord::Migration
  def self.up
    add_column :payments, :ip_address, :string
    add_column :payments, :success, :boolean

    add_column :payments, :paypal_express_token, :string
    add_column :payments, :paypal_express_payer_id, :string
    add_column :payments, :paypal_express_authorization, :string
    add_column :payments, :paypal_express_message, :string
    add_column :payments, :paypal_express_params, :text
  end

  def self.down
    remove_column :payments, :ip_address
    remove_column :payments, :success

    remove_column :payments, :paypal_express_token
    remove_column :payments, :paypal_express_payer_id
    remove_column :payments, :paypal_express_authorization
    remove_column :payments, :paypal_express_message
    remove_column :payments, :paypal_express_params
  end
end
