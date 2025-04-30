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
      # TODO: this should probably check exp_to_next_level?(self.level + 1)??
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
    exp_to_add = other.detailed_exp[2]
    level = self.level
    current = self.detailed_exp[0]
    to_next_level = self.detailed_exp[1]

    while exp_to_add > 0 do
      # First check if total incoming exp will not cause a level increase, in that case we just add the progress
      # and quit
      if current + exp_to_add < to_next_level
        self.detailed_exp[0] += exp_to_add
        self.detailed_exp[2] = self.exp = self.detailed_exp[2] + exp_to_add

        exp_to_add -= exp_to_add

        break
      end

      # Otherwise, gradually drain exp_to_add by increments of the amount required for next levels and level up one by one until we hit <0
      # or the above condition in the next loop
      remaining_current_level_exp = to_next_level - current # 30

      if remaining_current_level_exp > exp_to_add
        # Ain't no way we're here because it should be taken care of by the above check
        logger.error("Level recalculation error", { exp: self, other: })
        raise RuntimeError, "Something is messed up in merging levels"
      end

      self.detailed_exp[0] = (current + remaining_current_level_exp) - to_next_level # Should be 0
      self.detailed_exp[1] = DiscordHelper.exp_to_next_level?(level)
      self.detailed_exp[2] = self.exp = self.detailed_exp[2] + remaining_current_level_exp
      self.level += 1

      # Prepare for next iteration
      exp_to_add -= remaining_current_level_exp
      level = self.level
      current = self.detailed_exp[0]
      to_next_level = self.detailed_exp[1]
    end

    self.message_count += other.message_count

    self.save!
    other.destroy!

    return self
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
