class AddPrivateFlagToAdminSettings < ActiveRecord::Migration
  def change
    add_column :admin_settings, :is_private, :boolean, default: false, null: false
  end
end
