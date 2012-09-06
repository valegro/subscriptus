class AddTemplateFieldsToPublication < ActiveRecord::Migration
  def self.up
    add_column :publications, :template_name, :string
    add_column :publications, :custom_domain, :string
  end

  def self.down
    remove_column :publications, :custom_domain
    remove_column :publications, :template_name
  end
end