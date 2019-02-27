class AddMaxImageCountPerPlaceToMaps < ActiveRecord::Migration
  def change
    add_column :maps, :images_per_post, :integer, null: false, default: 3
  end
end
