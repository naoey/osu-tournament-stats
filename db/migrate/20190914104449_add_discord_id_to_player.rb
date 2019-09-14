class AddDiscordIdToPlayer < ActiveRecord::Migration[6.0]
  def up
    add_column Player, 'osu_id', 'integer'
    add_column Player, 'discord_id', 'string'
    add_column Player, 'discord_last_spoke', 'datetime'

    execute 'UPDATE players SET osu_id = id'
  end
end
