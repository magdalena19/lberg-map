class RemoveAutoTranslateFromMaps < ActiveRecord::Migration
  def change
    remove_column :maps, :auto_translate
  end
end
