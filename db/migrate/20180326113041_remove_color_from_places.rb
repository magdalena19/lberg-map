class RemoveColorFromPlaces < ActiveRecord::Migration
  def change
    remove_column :places, :color
  end
end
