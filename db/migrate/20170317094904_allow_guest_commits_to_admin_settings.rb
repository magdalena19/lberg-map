class AllowGuestCommitsToAdminSettings < ActiveRecord::Migration
  def change
    add_column :admin_settings, :allow_guest_commits, :boolean, default: true, null: false
  end
end
