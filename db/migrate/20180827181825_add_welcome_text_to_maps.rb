class AddWelcomeTextToMaps < ActiveRecord::Migration
  def change
    add_column :maps, :show_map_description_on_visit, :boolean, null: false, default: false
  end
end
