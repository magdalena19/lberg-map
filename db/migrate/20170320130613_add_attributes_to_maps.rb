class AddAttributesToMaps < ActiveRecord::Migration
  def change
    add_column :maps, :title, :string
    add_column :maps, :description, :text
    add_column :maps, :imprint, :text
    add_column :maps, :is_public, :boolean, default: false, null: false
    add_column :maps, :public_token, :string
    add_column :maps, :secret_token, :string, null: false
  end
end
