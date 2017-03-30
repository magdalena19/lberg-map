class AddUserToTokens < ActiveRecord::Migration
  def change
    add_reference :activation_tokens, :user, index: true, foreign_key: true
  end
end
