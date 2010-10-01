class AddRecurentIdColumnToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :recurrent_id, :string, :default => nil # the customer_id that is used to refere to user's recurrent profile in secure pay
  end

  def self.down
    remove_column :users, :recurrent_id
  end
end
