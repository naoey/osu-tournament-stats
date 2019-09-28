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

    # migrate all the old 1v1 matches by making a team for each player
    Match.all.each do |m|
      red_team = MatchTeam.create(
        match: m,
        captain: m.player_red,
        players: [m.player_red]
      )

      red_team.save!

      blue_team = MatchTeam.create(
        match: m,
        captain: m.player_blue,
        players: [m.player_blue]
      )

      blue_team.save!

      m.red_team = red_team
      m.blue_team = blue_team

      m.winner = if m.winner_id == m.player_red.id
                   red_team
                 else
                   blue_team
                 end

      m.save!
    end

    add_index :match_teams_players, %i[match_team_id player_id], unique: true

    add_foreign_key :matches, :match_teams, column: :winner, on_delete: :restrict

    remove_column :matches, :player_blue_id
    remove_column :matches, :player_red_id
    remove_column :matches, :winner
    remove_column :matches, :api_json
  end
end
