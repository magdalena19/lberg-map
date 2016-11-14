class AddColumnNameToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :name, :string, null: false
  end
end
