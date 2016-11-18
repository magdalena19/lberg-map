class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :sender_name
      t.string :sender_email
      t.string :subject
      t.text :text

      t.timestamps null: false
    end
  end
end
