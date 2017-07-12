class AddMultiColorPoisToAdminSettings < ActiveRecord::Migration
  def change
    add_column :admin_settings, :multi_color_pois, :boolean, default: true, null: false
    add_column :admin_settings, :default_poi_color, :string, default: 'red', null: false
  end
end
