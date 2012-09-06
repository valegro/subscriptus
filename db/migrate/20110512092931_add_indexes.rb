class AddIndexes < ActiveRecord::Migration
  def self.up
    add_index :users, :email, :unique => true
    add_index :subscriptions, :publication_id
    add_index :offers, :name, :unique => true
    add_index :publications, :name, :unique => true
  end

  def self.down
    remove_index :users, :email
    remove_index :subscriptions, :publication_id
    remove_index :offers, :name
    remove_index :publications, :name
  end
end
