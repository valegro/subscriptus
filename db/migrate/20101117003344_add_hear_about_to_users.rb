class AddHearAboutToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :hear_about, :string
  end

  def self.down
    remove_column :users, :hear_about
  end
end
