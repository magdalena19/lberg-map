class CreateCategoriesTranslations < ActiveRecord::Migration
  def change
    remove_column :categories, :name
    Category.create_translation_table! name: :string
  end
end
