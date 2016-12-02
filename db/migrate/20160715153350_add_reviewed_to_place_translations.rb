class AddReviewedToPlaceTranslations < ActiveRecord::Migration
  def change
    add_column :place_translations, :reviewed, :boolean, default: false, null: false
  end
end
