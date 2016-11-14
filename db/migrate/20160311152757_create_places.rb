class CreatePlaces < ActiveRecord::Migration
  def change
    create_table :places do |t|
      t.float :latitude, null: false
      t.float :longitude, null: false

      t.timestamps null: false
    end
  end
end
