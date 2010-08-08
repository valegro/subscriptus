class CreatePublications < ActiveRecord::Migration
  def self.up
    create_table :publications do |t|
      t.string :name
      t.text :description
      t.string :image_file_name
      t.string :image_content_type
      t.integer :image_file_size
      t.timestamp :image_updated_at
      t.timestamps
    end
  end

  def self.down
    drop_table :publications
  end
end
