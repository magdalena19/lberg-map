class AddReviewdToPlaces < ActiveRecord::Migration
  def change
    add_column :places, :reviewed, :boolean, default: false, null: false
  end
end
