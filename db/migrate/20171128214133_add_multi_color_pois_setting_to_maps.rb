class AddMultiColorPoisSettingToMaps < ActiveRecord::Migration
  def change
    add_column :maps, :multi_color_pois, :boolean, null: false, default: true
    add_column :maps, :default_poi_color, :string, null: false, default: 'red'

    remove_column :admin_settings, :multi_color_pois
    remove_column :admin_settings, :default_poi_color
  end
end
