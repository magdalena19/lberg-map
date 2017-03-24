class DeleteTagsFromMessages < ActiveRecord::Migration
  def change
    remove_column :messages, :tag
  end
end
