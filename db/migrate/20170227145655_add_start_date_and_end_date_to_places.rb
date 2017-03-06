class AddStartDateAndEndDateToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :start_date, :datetime
    add_column :places, :end_date, :datetime
  end
end
