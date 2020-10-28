class CreateTournaments < ActiveRecord::Migration[5.2]
  def change
    create_table :tournaments do |t|
      t.string :name, null: false
      t.bigint :host_player_id
      t.datetime :start_date
      t.datetime :end_date

      t.timestamps
    end

    add_column :matches, :tournament_id, :bigint

    add_foreign_key :matches, :tournaments, {
      column: 'tournament_id',
      # primary_key: 'online_id',
      on_update: :cascade,
      on_delete: :cascade,
    }

    add_foreign_key :tournaments, :players, {
      column: 'host_player_id',
      on_update: :cascade,
      on_delete: :nullify,
    }
  end
end
