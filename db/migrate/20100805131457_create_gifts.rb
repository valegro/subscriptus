class CreateGifts < ActiveRecord::Migration
  def self.up
    create_table :gifts do |t|
      t.string :name
      t.text :description
      t.string :gift_image_file_name
      t.string :gift_image_content_type
      t.integer :gift_image_file_size
      t.timestamp :gift_image_updated_at
      t.integer :on_hand
      t.timestamps
    end
  end

  def self.down
    drop_table :gifts
  end
end
