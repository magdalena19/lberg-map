class AddAutoTranslatedFlagToCategories < ActiveRecord::Migration
  def change
    add_column :category_translations, :auto_translated, :boolean, default: false, null: false
  end
end
