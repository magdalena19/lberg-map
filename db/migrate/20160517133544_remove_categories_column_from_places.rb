class RemoveCategoriesColumnFromPlaces < ActiveRecord::Migration
  def change
  	remove_column :places, :categories
  end
end
