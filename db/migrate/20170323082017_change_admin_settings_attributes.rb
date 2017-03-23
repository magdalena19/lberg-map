class ChangeAdminSettingsAttributes < ActiveRecord::Migration
  def change
    remove_column :admin_settings, :auto_translate
    remove_column :admin_settings, :is_private
    remove_column :admin_settings, :maintainer_email_address
    remove_column :admin_settings, :translation_engine
    remove_column :admin_settings, :allow_guest_commits

    add_column :admin_settings, :admin_email_address, :string, null: false, default: 'foo@bar.org'
  end
end
