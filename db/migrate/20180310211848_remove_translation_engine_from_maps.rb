class RemoveTranslationEngineFromMaps < ActiveRecord::Migration
  def change
    remove_column :maps, :translation_engine, :string
  end
end
