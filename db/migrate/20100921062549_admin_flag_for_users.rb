class AdminFlagForUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.string :role
    end
    User.update_all "role = 'subscriber'"
  end

  def self.down
    change_table :users do |t|
      t.remove :role
    end
  end
end
