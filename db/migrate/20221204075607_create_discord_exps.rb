class CreateDiscordExps < ActiveRecord::Migration[7.0]
  def up
    create_table :discord_exps do |t|
      t.references :player, foreign_key: true, null: false, type: :bigint
      t.references :discord_server, foreign_key: true, null: false, type: :bigint

      t.column :exp, :bigint, null: false, default: 0
      t.column :detailed_exp, :json, null: false
      t.column :level, :int, null: false, default: 0
      t.column :message_count, :int, null: false, default: 0

      t.index %i[player_id discord_server_id], name: 'uniq_player_exp_per_server', unique: true

      t.timestamps
    end

    add_column :discord_servers, :exp_enabled, :boolean, default: false, null: false
  end

  def down
    drop_table :discord_exps
    remove_column :discord_servers, :exp_enabled
  end
end
