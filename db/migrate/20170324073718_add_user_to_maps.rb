class AddUserToMaps < ActiveRecord::Migration
  def change
    add_reference :maps, :user, index: true, foreign_key: true
  end
end
