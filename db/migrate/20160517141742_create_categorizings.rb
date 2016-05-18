class CreateCategorizings < ActiveRecord::Migration
  def change
    create_table :categorizings do |t|
      t.belongs_to :place, index: true, foreign_key: true
      t.belongs_to :category, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
