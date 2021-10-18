class AddUniqueDiscordId < ActiveRecord::Migration[6.0]
  def up
    # There may have been many dummy users created before they were linked to osu! IDs that failed to get cleaned up. Delete them all
    # before attempting to add the unique constraint or constraint will fail as these will have duplicate discord IDs.
    dummy_players = Player.where(name: nil)

    dummy_players.each do |p|
      p.osu_auth_requests.destroy_all
      p.destroy
    end

    add_column :players, :osu_verified_on, :datetime

    Player.all.each do |p|
      if p.osu_verified
        p.osu_verified_on = p.osu_auth_requests.order(:updated_on).last.updated_on
      end
    end

    add_index :players, :discord_id, unique: true, name: 'index_unique_discord_ids'
  end

  def down
    remove_column :players, :osu_verified_on
    remove_index :players, name: 'index_unique_discord_ids'
  end
end
