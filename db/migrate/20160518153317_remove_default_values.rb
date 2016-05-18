class RemoveDefaultValues < ActiveRecord::Migration
  def change
    change_column_default(:places, :street, nil)
    change_column_default(:places, :postal_code, nil)
    change_column_default(:places, :city, nil)
  end
end
