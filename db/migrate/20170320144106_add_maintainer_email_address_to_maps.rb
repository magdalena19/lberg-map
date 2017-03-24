class AddMaintainerEmailAddressToMaps < ActiveRecord::Migration
  def change
    add_column :maps, :maintainer_email_address, :string
  end
end
