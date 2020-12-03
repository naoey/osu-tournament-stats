class NullableMatchTournament < ActiveRecord::Migration[6.0]
  def change
    change_column :matches, :tournament_id, :bigint, null: true
  end
end
