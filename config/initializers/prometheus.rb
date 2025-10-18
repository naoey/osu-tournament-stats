# frozen_string_literal: true

require 'prometheus/client'

require_relative '../../app/helpers/application_helper'

prometheus = Prometheus::Client.registry

discord_bot_restarts = prometheus.counter(
  :discord_bot_restarts,
  docstring: "Number of times the Discord bot was restarted by watchdog due to healthcheck failure",
)

discord_bot_commands = prometheus.counter(
  :discord_bot_commands,
  docstring: "Commands successfully processed by the Discord bot",
  labels: [:command],
)

ApplicationHelper::Notifications.subscribe("discord.bot_force_restarted") do
  discord_bot_restarts.increment
end

ApplicationHelper::Notifications.subscribe("discord.command_handled") do |payload|
  discord_bot_commands.increment(labels: { command: payload[:command] })
end
