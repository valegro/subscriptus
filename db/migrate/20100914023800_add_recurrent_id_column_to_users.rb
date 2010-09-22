class AddRecurrentIdColumnToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :recurrent_id, :string
  end

  def self.down
    remove_column :users, :recurrent_id
  end
end
