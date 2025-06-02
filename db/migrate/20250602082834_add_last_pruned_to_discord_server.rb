class AddLastPrunedToDiscordServer < ActiveRecord::Migration[8.0]
  def change
    add_column(:discord_servers, :last_pruned, :timestamp, null: true)
  end
end
