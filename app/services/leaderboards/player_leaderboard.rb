module PlayerLeaderboard
  ORDERING = {
    name: 'players.name',
    accuracy: 'AVG(match_scores.accuracy',
    score: 'AVG(match_scores.score)',
    play_count: 'COUNT(*)',
  }.freeze

  def self.get_leaderboard(limit = nil, offset = 0, order: 'score', descending: true)
    q = MatchScore
      .joins(:player)
      .select('players.name AS player_name, AVG(match_scores.score) AS score, ROUND(AVG(match_scores.accuracy) * 100, 2) AS average_acc, COUNT(*) AS maps_played')
      .group('match_scores.player_id')
      .order("#{ORDERING[order.to_sym] || ORDERING[:score]} #{descending ? 'DESC' : 'ASC'}")

    q = q.limit(limit) if limit.is_a?(Integer)
    q = q.offset(offset) if offset > 0

    q.all
  end
end
