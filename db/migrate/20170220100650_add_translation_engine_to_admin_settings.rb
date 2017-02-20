class AddTranslationEngineToAdminSettings < ActiveRecord::Migration
  def change
    add_column :admin_settings, :translation_engine, :string, default: 'bing', null: false
  end
end
