class AddTwitterEncrAttrToMap < ActiveRecord::Migration
  def change
    add_column :maps, :encrypted_twitter_api_key, :string
    add_column :maps, :encrypted_twitter_api_key_iv, :string

    add_column :maps, :encrypted_twitter_api_secret_key, :string
    add_column :maps, :encrypted_twitter_api_secret_key_iv, :string

    add_column :maps, :encrypted_twitter_access_token, :string
    add_column :maps, :encrypted_twitter_access_token_iv, :string

    add_column :maps, :encrypted_twitter_access_token_secret, :string
    add_column :maps, :encrypted_twitter_access_token_secret_iv, :string
  end
end
