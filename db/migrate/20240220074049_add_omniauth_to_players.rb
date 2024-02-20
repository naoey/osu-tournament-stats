class AddOmniauthToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :provider, :string
    add_column :players, :uid, :string
  end
end
