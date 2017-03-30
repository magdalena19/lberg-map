class CreateActivationTokens < ActiveRecord::Migration
  def change
    create_table :activation_tokens do |t|
      t.string :token, null: false

      t.timestamps null: false
    end
  end
end
