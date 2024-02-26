class AddOmniauthToPlayers < ActiveRecord::Migration[7.0]
  def change
    add_column :players, :provider, :string
    add_column :players, :uid, :string
    add_column :players, :osu_profile, :json
    add_column :players, :country_code, :string
    add_column :players, :avatar_url, :string
    add_column :players, :discord_profile, :json
    add_column :players, :discord_registered_on, :datetime

    rename_column :players, :osu_verified_on, :osu_registered_on

    remove_column :players, :osu_verified

    drop_table :osu_auth_requests do |t|
      t.string "nonce", null: false
      t.boolean "resolved", default: false, null: false
      t.bigint "player_id", null: false
      t.bigint "discord_server_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["discord_server_id"], name: "index_osu_auth_requests_on_discord_server_id"
      t.index ["player_id"], name: "index_osu_auth_requests_on_player_id"
    end
  end
end
