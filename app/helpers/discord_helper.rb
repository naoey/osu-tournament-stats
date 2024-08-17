module DiscordHelper
  INITIAL_EXP = [0, 100, 0]

  ## Calculates the amount of exp required to to attain current_level + 1 level, using the amount of exp currently held.
  #
  # @param [Integer] current_level
  # @param [Integer] current_exp
  def self.exp_to_next_level?(current_level, current_exp = 0)
    5 * (current_level**2) + (50 * current_level) + 100 - current_exp
  end

  def self.sanitise_username(name)
    name.encode("UTF-8", "binary", invalid: :replace, undef: :replace, replace: "wang").truncate(255)
  end

  # Create an object that can be used for creating a PlayerAuth from a Discord User
  def self.identity_from_user(user)
    {
      username: user.global_name || user.username,
      id: user.id,
      joined_at: user.joined_at,
      bot_account: user.bot_account,
      discriminator: user.discriminator,
      avatar_id: user.avatar_id,
      public_flags: user.public_flags
    }.stringify_keys
  end
end
