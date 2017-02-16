class AddFurtherSettingsToAdminSettings < ActiveRecord::Migration
  def change
    add_column :admin_settings, :app_title, :string, null: false, default: 'Generic title'
    add_column :admin_settings, :maintainer_email_address, :string, default: 'foo@bar.org'
  end
end
