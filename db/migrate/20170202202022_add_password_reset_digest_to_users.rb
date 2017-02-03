class AddPasswordResetDigestToUsers < ActiveRecord::Migration
  def change
    add_column :users, :password_reset_digest, :string
  end
end
