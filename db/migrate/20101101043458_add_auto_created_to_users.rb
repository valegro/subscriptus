class AddAutoCreatedToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :auto_created, :boolean
  end

  def self.down
    remove_column :users, :auto_created
  end
end
