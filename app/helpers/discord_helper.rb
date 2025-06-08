module DiscordHelper
  LOGGER = SemanticLogger[DiscordHelper]

  INITIAL_EXP = [0, 100, 0]

  ## Calculates the amount of exp required to to attain current_level + 1 level, using the amount of exp currently held.
  #
  # @param [Integer] current_level
  # @param [Integer] current_exp
  def self.exp_to_next_level?(current_level, current_exp = 0)
    5 * (current_level ** 2) + (50 * current_level) + 100 - current_exp
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

  ##
  # Invokes the given block if any changes are detected to files under lib/discord/commands since the last commit SHA
  # stored in tmp/discord_commands.lock, or if no such file is found.
  def self.register_commands?
    raise "Block is required" unless block_given?

    commands_dir = Rails.root.join("lib/discord/commands")
    lock_file = Rails.root.join("tmp/discord_commands.lock")
    current_sha = `git rev-parse HEAD`.strip

    unless File.exist?(lock_file)
      yield
      File.write(lock_file, current_sha)
      return
    end

    last_sha = File.read(lock_file).strip

    if last_sha == current_sha
      LOGGER.info("Commands already registered for current git SHA; skipping")
      return
    end

    changed = `git diff --name-only #{last_sha} #{current_sha} -- #{commands_dir}`.lines.any?

    if changed
      LOGGER.info("Commands have changed since last git SHA; registering new commands...", { changed: })
      yield
      File.write(lock_file, current_sha)
    end
  end
end
