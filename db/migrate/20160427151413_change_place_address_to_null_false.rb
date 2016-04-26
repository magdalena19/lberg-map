class ChangePlaceAddressToNullFalse < ActiveRecord::Migration
  def change
    change_column :places, :street, :string, :default => 'Default street', :null => false
    change_column :places, :postal_code, :string, :default => 'Default postal code', :null => false
    change_column :places, :city, :string, :default => 'Default city', :null => false
  end
end
