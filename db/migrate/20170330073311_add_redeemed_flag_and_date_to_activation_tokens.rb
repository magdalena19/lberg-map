class AddRedeemedFlagAndDateToActivationTokens < ActiveRecord::Migration
  def change
    add_column :activation_tokens, :redeemed, :boolean, default: false, null: false
    add_column :activation_tokens, :redeemed_on, :date
  end
end
