class AddTwitterAttrToMaps < ActiveRecord::Migration
  def change
    add_column :maps, :twitter_api_key, :string
    add_column :maps, :twitter_api_secret_key, :string
    add_column :maps, :twitter_access_token, :string
    add_column :maps, :twitter_access_token_secret, :string
    add_column :maps, :twitter_autopost_message, :string
  end
end
