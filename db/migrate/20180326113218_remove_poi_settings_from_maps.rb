class RemovePoiSettingsFromMaps < ActiveRecord::Migration
  def change
    remove_column :maps, :multi_color_pois
    remove_column :maps, :default_poi_color
  end
end
