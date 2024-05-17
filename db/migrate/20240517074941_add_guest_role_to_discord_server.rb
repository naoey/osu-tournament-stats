class AddGuestRoleToDiscordServer < ActiveRecord::Migration[7.0]
  def change
    add_column :discord_servers, :guest_role_id, :bigint, required: false
    remove_column :discord_servers, :registration_channel_id, :bigint
  end
end
