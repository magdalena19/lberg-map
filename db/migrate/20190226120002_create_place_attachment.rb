class CreatePlaceAttachment < ActiveRecord::Migration
  def change
    create_table :place_attachments do |t|
      t.integer :place_id, null: false
      t.string :image, null: false
    end
  end
end
