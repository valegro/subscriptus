class AddValidConcessionHolderToUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.column :valid_concession_holder, :boolean, :default => false
    end
  end

  def self.down
    change_table :users do |t|
      t.remove_column :valid_concession_holder
    end
  end
end
