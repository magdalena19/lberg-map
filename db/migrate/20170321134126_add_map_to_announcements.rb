class AddMapToAnnouncements < ActiveRecord::Migration
  def change
    add_reference :announcements, :map, index: true, foreign_key: true
  end
end
