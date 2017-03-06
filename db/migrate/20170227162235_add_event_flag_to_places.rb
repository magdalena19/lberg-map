class AddEventFlagToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :event, :boolean, null: false, default: false
  end
end
