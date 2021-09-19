class AddVerificationLogChannelToDiscordServer < ActiveRecord::Migration[6.0]
  def up
    add_column :discord_servers, :verification_log_channel_id, :bigint
  end

  def down
    remove_column :discord_servers, :verification_log_channel_id
  end
end
