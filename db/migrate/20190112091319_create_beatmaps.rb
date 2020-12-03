class CreateBeatmaps < ActiveRecord::Migration[5.2]
  def change
    create_table :beatmaps do |t|
      t.string :name
      t.bigint :online_id
      t.float :star_difficulty
      t.string :difficulty_name
      t.bigint :max_combo

      t.timestamps
    end
  end
end
