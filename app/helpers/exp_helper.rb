module ExpHelper

  ## Calculates the amount of exp required to to attain current_level + 1 level, using the amount of exp currently held.
  #
  # @param [Object] current_level
  # @param [Object] current_exp
  def self.exp_to_next_level?(current_level, current_exp = 0)
    5 * (current_level ** 2) + (50 * current_level) + 100 - current_exp
  end
end
