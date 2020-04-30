class StoreFullCombosAndMapWins < ActiveRecord::Migration[6.0]
  def up
    change_table :match_scores do |t|
      t.column :is_full_combo, :boolean
      t.column :is_win, :boolean

      MatchScore.all.each do |score|
        # find this player's team id
        if score.match.red_team.players.include?(score.player)
          player_team = score.match.red_team
          other_team = score.match.blue_team
        else
          player_team = score.match.blue_team
          other_team = score.match.red_team
        end

        # find both teams total scores
        player_team_score = MatchScore
          .where({ player: player_team.players, match: score.match, beatmap: score.beatmap })
          .sum(:score)

        other_team_score = MatchScore
          .where({ player: other_team.players, match: score.match, beatmap: score.beatmap })
          .sum(:score)

        score.update(
          is_win: player_team_score > other_team_score,
          is_full_combo: score.count_miss.zero? && (score.beatmap.max_combo - score.max_combo) <= 0.01 * score.beatmap.max_combo
        )
      end
    end
  end

  def down
    remove_column :match_scores, :is_win
    remove_column :match_scores, :is_full_combo
  end
end
