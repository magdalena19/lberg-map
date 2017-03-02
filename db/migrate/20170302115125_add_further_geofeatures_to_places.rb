class AddFurtherGeofeaturesToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :country, :string
    add_column :places, :district, :string
    add_column :places, :federal_state, :string
  end
end
