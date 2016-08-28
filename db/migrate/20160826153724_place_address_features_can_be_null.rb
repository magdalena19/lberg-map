class PlaceAddressFeaturesCanBeNull < ActiveRecord::Migration
  def change
    change_column :places, :street, :string, :null => true
    change_column :places, :postal_code, :string, :null => true
    change_column :places, :city, :string, :null => true
  end
end
