class AddDarkModeRemoveLastSpoke < ActiveRecord::Migration[8.0]
  def up
    remove_column(:players, :discord_last_spoke, :timestamp)
    add_column(
      :players,
      :ui_config,
      :json,
      null: false
    )

    Player.update(ui_config: { preferred_colour_scheme: 0 })
  end

  def down
    add_column(:players, :discord_last_spoke, :timestamp)
    remove_column(:players, :ui_config, :json)
  end
end
