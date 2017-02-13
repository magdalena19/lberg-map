class CreateAdminSettings < ActiveRecord::Migration
  def change
    create_table :admin_settings do |t|

      t.timestamps null: false
    end
  end
end
