class AddMarkerSettingsToCategories < ActiveRecord::Migration
  def change
    add_column :categories, :marker_color, :string, null: false, default: 'black'
    add_column :categories, :marker_shape, :string, null: false, default: 'circle'
    add_column :categories, :marker_icon_class, :string, null: false, default: 'fa-star'
  end
end
