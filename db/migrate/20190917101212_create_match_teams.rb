class CreateMatchTeams < ActiveRecord::Migration[6.0]
  def up
    create_table :match_teams do |t|
      t.string :name
      t.integer :captain_id, null: false

      t.references :match

      t.timestamps
    end

    create_join_table :match_teams, :players

    add_foreign_key :match_teams, :players, column: :captain_id

    add_column :matches, :winner_id, :integer
    add_column :matches, :red_team_id, :integer
    add_column :matches, :blue_team_id, :integer

    rename_column :matches, :winner, :awinner

    # migrate all the old 1v1 matches by making a team for each player
    Match.all.each do |m|
      red_player = Player.find_by_osu_id(m.player_red_id)
      red_team = MatchTeam.create(
        captain: red_player,
        players: [red_player]
      )

      red_team.save!

      blue_player = Player.find_by_osu_id(m.player_blue_id)
      blue_team = MatchTeam.create(
        captain: blue_player,
        players: [blue_player]
      )

      blue_team.save!

      m.red_team = red_team
      m.blue_team = blue_team

      m.winner = if m.awinner == red_player.osu_id
                   red_team
                 elsif m.awinner == blue_player.osu_id
                   blue_team
                 end

      m.save!
    end

    add_index :match_teams_players, %i[match_team_id player_id], unique: true

    add_foreign_key :matches, :match_teams, column: :winner_id, on_delete: :restrict

    remove_column :matches, :player_blue_id
    remove_column :matches, :player_red_id
    remove_column :matches, :awinner
    remove_column :matches, :api_json
  end
end
