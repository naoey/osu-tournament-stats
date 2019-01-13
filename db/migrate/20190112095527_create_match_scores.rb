class CreateMatchScores < ActiveRecord::Migration[5.2]
  def change
    create_table :match_scores do |t|
      t.integer :match_id
      t.integer :player_id
      t.integer :beatmap_id
      t.integer :online_game_id
      t.text :raw_json

      t.timestamps
    end

    add_index "match_scores", ["player_id"], name: "index_match_scores_on_player", using: :btree
  end
end
