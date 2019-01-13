class CreateMatches < ActiveRecord::Migration[5.2]
  def change
    create_table :matches do |t|
      t.integer :online_id
      t.integer :player_red
      t.integer :player_blue
      t.text :api_json
      t.datetime :match_timestamp

      t.timestamps
    end

    add_index "matches", ["player_red"], name: "index_matches_on_player_red", using: :btree
    add_index "matches", ["player_blue"], name: "index_matches_on_player_blue", using: :btree
  end
end
