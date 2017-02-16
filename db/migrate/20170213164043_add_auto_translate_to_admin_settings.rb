class AddAutoTranslateToAdminSettings < ActiveRecord::Migration
  def change
    add_column :admin_settings, :auto_translate, :boolean, default: true, null: false
  end
end
