class AddSupportedLanguagesToMaps < ActiveRecord::Migration
  def change
    add_column :maps, :supported_languages, :text, array: true, default: [I18n.default_locale], null: false
  end
end
