class AddUserActivationTokensToAdminSetting < ActiveRecord::Migration
  def change
    add_column :admin_settings, :user_activation_tokens, :integer, null: false, default: 2
  end
end
