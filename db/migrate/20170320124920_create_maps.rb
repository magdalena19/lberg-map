class CreateMaps < ActiveRecord::Migration
  def change
    create_table :maps do |t|
      t.timestamps null: false
    end
  end
end
