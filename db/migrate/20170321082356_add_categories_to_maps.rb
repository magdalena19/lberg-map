class AddCategoriesToMaps < ActiveRecord::Migration
  def change
    add_reference :categories, :map, index: true, foreign_key: true
  end
end
