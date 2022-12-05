module DiscordHelper
  INITIAL_EXP = [0, 100, 0]

  ## Calculates the amount of exp required to to attain current_level + 1 level, using the amount of exp currently held.
  #
  # @param [Integer] current_level
  # @param [Integer] current_exp
  def self.exp_to_next_level?(current_level, current_exp = 0)
    5 * (current_level ** 2) + (50 * current_level) + 100 - current_exp
  end

  def self.sanitise_username(name)
    name.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: 'wang').truncate(255)
  end
end
