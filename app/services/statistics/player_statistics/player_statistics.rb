module PlayerStatistics
  class PlayerStatistic < Statistic
    attr_reader :player

    def initialize(player)
      @player = player
    end

    protected

    def validate!
      if @player.nil? || !@player.instance_of?(Player)
        raise ArgumentError, "#{self.class.name} expected to be initialised with a valid Player object, received #{Player.class}"
      end
    end
  end
end
