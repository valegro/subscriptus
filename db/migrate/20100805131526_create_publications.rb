class CreatePublications < ActiveRecord::Migration
  def self.up
    create_table :publications do |t|
      t.string :name
      t.text :description
      t.string :publication_image_file_name
      t.string :publication_image_content_type
      t.integer :publication_image_file_size
      t.timestamp :publication_image_updated_at
      t.timestamps
    end
  end

  def self.down
    drop_table :publications
  end
end
