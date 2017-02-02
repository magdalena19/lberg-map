class AddPasswordResetTimestampToUsers < ActiveRecord::Migration
  def change
    add_column :users, :password_reset_timestamp, :datetime
  end
end
