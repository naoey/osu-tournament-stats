require_relative "../helpers/discord_helper"

class DiscordExp < ApplicationRecord
  belongs_to :player, optional: false
  belongs_to :discord_server, optional: false

  def add_exp()
    if Rails.env.production? && self.updated_at && Time.now - self.updated_at < 60.seconds
      raise RuntimeError, "Cannot update exp within 60s of last update!"
    end

    exp = rand(15..25)

    current = self.detailed_exp[0]
    to_next_level = self.detailed_exp[1]

    self.message_count += 1

    if current + exp > to_next_level
      self.detailed_exp[0] = (current + exp) - to_next_level
      self.detailed_exp[1] = DiscordHelper.exp_to_next_level?(self.level)
      self.detailed_exp[2] = self.exp = self.detailed_exp[2] + exp
      self.level += 1

      self.save!

      logger.info("Exp levelled up to carrying over #{self.detailed_exp[0]} exp", { exp: self, user: self.player.discord })

      ApplicationHelper::Notifications.notify("player.discord_level_up", { exp: self })
    else
      self.detailed_exp[0] += exp
      self.detailed_exp[2] = self.exp = self.detailed_exp[2] + exp

      self.save!
    end
  end

  ## Merges another DiscordExp into this one and recalculates levels.
  def merge(other)
    current = self.detailed_exp[0]
    to_next_level = self.detailed_exp[1]
    remaining_other_exp = other.detailed_exp[2]

    while remaining_other_exp > 0 do
      if current + remaining_other_exp > to_next_level
        delta = remaining_other_exp - to_next_level
        remaining_other_exp -= to_next_level

        self.detailed_exp[0] = (current + delta) - to_next_level
        self.detailed_exp[1] = DiscordHelper.exp_to_next_level?(self.level)
        self.detailed_exp[2] = self.exp = self.detailed_exp[2] + delta
        self.level += 1
      else
        self.detailed_exp[0] += remaining_other_exp
        self.detailed_exp[2] = self.exp = self.detailed_exp[2] + remaining_other_exp

        self.save!
      end

      self.save!

      logger.info("Exp levelled up to carrying over #{self.detailed_exp[0]} exp", { exp: self, user: self.player.discord })
      ApplicationHelper::Notifications.notify("player.discord_level_up", { exp: self })
    end

  end

  ##
  # Returns the list of role IDs and the corresponding thresholds from the server's exp roles configuration that this user should have
  # acquired for the given exp amount.
  def get_role_ids()
    server = Rails.cache.read("discord_bot/servers")&.find { |s| s["id"] == self.discord_server.id }

    return [] if server.nil?

    roles_config = server["exp_roles_config"]

    return [] if roles_config.nil?

    thresholds = roles_config.sort_by { |r| r[0] }
    acquired_roles = []

    acquired_roles.push(thresholds.shift) while thresholds.count > 0 && self.exp > thresholds.first[0]

    return acquired_roles
  end

  def rank
    DiscordExp.all.order(exp: :desc).index(self) + 1
  end
end
