class AddAddressToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :postal_code, :string
    add_column :places, :street, :string
    add_column :places, :house_number, :string
    add_column :places, :city, :string
  end
end
