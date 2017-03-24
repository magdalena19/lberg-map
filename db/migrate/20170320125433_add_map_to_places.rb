class AddMapToPlaces < ActiveRecord::Migration
  def change
    add_reference :places, :map, index: true, foreign_key: true
  end
end
