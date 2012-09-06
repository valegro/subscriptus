class AddFieldsToPublication < ActiveRecord::Migration
  def self.up
    add_column :publications, :capabilities, :integer, :default => 0, :null => false
    add_column :publications, :terms_url, :string
  end

  def self.down
    remove_column :publications, :terms_url
    remove_column :publications, :capabilities
  end
end