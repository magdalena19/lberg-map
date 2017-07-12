class AddLastVisitToMaps < ActiveRecord::Migration
  def change
    add_column :maps, :last_visit, :date
  end
end
