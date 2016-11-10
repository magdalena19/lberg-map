class AddTagsToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :tag, :string
  end
end
