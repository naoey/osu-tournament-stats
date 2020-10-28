class CreateMatches < ActiveRecord::Migration[5.2]
  def change
    create_table :matches do |t|
      t.bigint :online_id
      t.bigint :player_red
      t.bigint :player_blue
      t.bigint :winner
      t.string :round_name
      t.text :api_json
      t.datetime :match_timestamp

      t.timestamps
    end

    add_index "matches", ["player_red"], name: "index_matches_on_player_red", using: :btree
    add_index "matches", ["player_blue"], name: "index_matches_on_player_blue", using: :btree
  end
end
