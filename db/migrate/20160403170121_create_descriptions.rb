class CreateDescriptions < ActiveRecord::Migration
  def change
    create_table :descriptions do |t|
      t.references :place, index: true, foreign_key: true
      t.string :language
      t.text :text
      
      t.timestamps null: false
    end
  end
end
