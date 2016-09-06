class AddFeaturesToPlace < ActiveRecord::Migration
  def change
    add_column :places, :phone, :string
    add_column :places, :email, :string
    add_column :places, :homepage, :string
  end
end
