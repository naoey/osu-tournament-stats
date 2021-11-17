class AddUniqueDiscordId < ActiveRecord::Migration[6.0]
  def up
    add_column :players, :osu_verified_on, :datetime

    # There may have been many dummy users created before they were linked to osu! IDs that failed to get cleaned up. Delete them all
    # before attempting to add the unique constraint or constraint will fail as these can have duplicate discord IDs.
    dummy_players = Player.where(name: nil)

    dummy_players.each do |p|
      p.osu_auth_requests.destroy_all
      p.destroy
    end

    add_index :players, :discord_id, unique: true, name: 'index_unique_discord_ids'

    Player.all.each do |p|
      p.osu_verified_on = p.osu_auth_requests.where(resolved: true).order(updated_at: :desc).first&.updated_at

      p.save!
    end
  end

  def down
    remove_column :players, :osu_verified_on
    remove_index :players, name: 'index_unique_discord_ids'
  end
end
