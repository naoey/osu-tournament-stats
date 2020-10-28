class AddIdToPlayerTeamsJoinTable < ActiveRecord::Migration[6.0]
  def change
    change_table :match_teams_players do |t|
      t.column :id, :bigint, primary_key: true
    end
  end
end
