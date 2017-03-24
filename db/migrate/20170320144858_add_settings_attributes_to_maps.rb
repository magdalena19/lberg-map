class AddSettingsAttributesToMaps < ActiveRecord::Migration
  def change
    add_column :maps, :allow_guest_commits, :boolean
    add_column :maps, :translation_engine, :string
    add_column :maps, :auto_translate, :boolean
  end
end
