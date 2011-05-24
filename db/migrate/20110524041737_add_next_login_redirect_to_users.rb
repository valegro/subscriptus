class AddNextLoginRedirectToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :next_login_redirect, :string
  end

  def self.down
    remove_column :users, :next_login_redirect
  end
end
