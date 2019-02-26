class RemoveImagesFromPlaces < ActiveRecord::Migration
  def change
    remove_column :places, :images
  end
end
