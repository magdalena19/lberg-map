class AddPrivacyPolicyAndAppImprintToAdminSettings < ActiveRecord::Migration
  def change
    add_column :admin_settings, :app_privacy_policy, :text
    add_column :admin_settings, :app_imprint, :text
  end
end
