class AddColorsToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :color, :string, default: 'purple', null: false
  end
end
