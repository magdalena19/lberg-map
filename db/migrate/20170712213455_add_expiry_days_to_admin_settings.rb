class AddExpiryDaysToAdminSettings < ActiveRecord::Migration
  def change
    add_column :admin_settings, :expiry_days, :integer, default: 30, null: false
  end
end
