class CreatePlacesTranslations < ActiveRecord::Migration
  def change
    Place.create_translation_table! description: :text
  end
end
