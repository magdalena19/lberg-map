class AddFutherTwitterAttrToMaps < ActiveRecord::Migration
  def change
    add_column :maps, :autopost_twitter, :boolean, null: false, default: false
    add_column :maps, :twitter_hashtags, :string
  end
end
