class AddColumnsToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :categories, :string, null: false
  end
end
