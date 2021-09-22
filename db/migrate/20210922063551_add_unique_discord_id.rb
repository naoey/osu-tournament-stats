class AddUniqueDiscordId < ActiveRecord::Migration[6.0]
  def up
    # There may have been many dummy users created before they were linked to osu! IDs that failed to get cleaned up. Delete them all
    # before attempting to add the unique constraint or constraint will fail as these will have duplicate discord IDs.
    Player.where(name: nil).destroy_all

    add_index :players, :discord_id, unique: true, name: 'index_unique_discord_ids'
  end

  def down
    remove_index :players, name: 'index_unique_discord_ids'
  end
end
