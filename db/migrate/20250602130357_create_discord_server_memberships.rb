class CreateDiscordServerMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :discord_server_memberships do |t|
      t.bigint(:player_id, null: false)
      t.bigint(:discord_server_id, null: false)

      t.json :roles

      t.timestamps

      t.foreign_key(:players, cascade: :delete, null: false)
      t.foreign_key(:discord_servers, cascade: :delete, null: false)

      t.index(%i[player_id discord_server_id], unique: true)
    end
  end
end
