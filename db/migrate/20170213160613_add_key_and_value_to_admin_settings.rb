class AddKeyAndValueToAdminSettings < ActiveRecord::Migration
  def change
    add_column :admin_settings, :key, :string, null: false
    add_column :admin_settings, :value, :string, null: false
  end
end
