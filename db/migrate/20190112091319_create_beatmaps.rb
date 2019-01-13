class CreateBeatmaps < ActiveRecord::Migration[5.2]
  def change
    create_table :beatmaps do |t|
      t.string :name
      t.integer :online_id
      t.float :star_difficulty
      t.string :difficulty_name
      t.integer :max_combo

      t.timestamps
    end
  end
end
