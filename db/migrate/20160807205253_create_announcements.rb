class CreateAnnouncements < ActiveRecord::Migration
  def change
    create_table :announcements do |t|
      t.belongs_to :user, index: true
      t.string :header, null: false
      t.string :content, null: false

      t.timestamps null: false
    end
  end
end
