class CreateDiscordServers < ActiveRecord::Migration[6.0]
  def up
    create_table :discord_servers do |t|
      t.bigint :discord_id, null: false
      t.bigint :registration_channel_id
      t.bigint :verified_role_id

      t.timestamps
    end

    add_index :discord_servers, :discord_id, unique: true
  end

  def down
    drop_table :discord_servers
  end
end
