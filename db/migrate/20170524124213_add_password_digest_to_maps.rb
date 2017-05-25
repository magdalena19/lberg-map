class AddPasswordDigestToMaps < ActiveRecord::Migration
  def change
    add_column :maps, :password_digest, :string
  end
end
