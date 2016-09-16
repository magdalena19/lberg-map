class AddAutotranslationColumnToPlaceTranslations < ActiveRecord::Migration
  def change
    add_column :place_translations, :auto_translated, :boolean, default: false, null: false
  end
end
