require_relative '../player_statistics.rb'

module TournamentStatistics
  class TournamentPlayerStatistic < ::PlayerStatistics::PlayerStatistic
    def initialize(player, tournament)
      @tournament = tournament

      super(player)
    end

    protected

    def validate!
      if @tournament.nil? || !@tournament.instance_of?(Tournament)
        raise ArgumentError, "#{self.class.name} expected to be initialised with a valid Tournament object, received #{@tournament.class}"
      end
    end
  end
end
