class AddPaymentGatewayTokenToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :payment_gateway_token, :string
  end

  def self.down
    remove_column :users, :payment_gateway_token
  end
end
