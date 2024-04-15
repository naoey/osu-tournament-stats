module PlayerLeaderboard
  ORDERING = {
    name: "players.name",
    score: "AVG(match_scores.score)",
    accuracy: "AVG(match_scores.accuracy)",
    play_count: "COUNT(*)"
  }.freeze

  def get_leaderboard(limit = nil, offset = 0, order: "score", ascending: true)
    sanitised_order = order ? ORDERING[order.to_sym] : ORDERING[:score]
    sanitised_order ||= ORDERING[:score]

    q =
      MatchScore
        .joins(:player)
        .select(
          "players.name AS player_name, AVG(match_scores.score) AS score, ROUND(AVG(match_scores.accuracy) * 100, 2) AS average_acc, COUNT(*) AS play_count"
        )
        .group("match_scores.player_id")
        .order("#{sanitised_order} #{ascending ? "ASC" : "DESC"}")

    q = q.limit(limit) if limit.is_a?(Integer)
    q = q.offset(offset) if offset > 0

    q.all.map { |s| { player_name: s.player_name, score: s.score, average_acc: s.average_acc, play_count: s.play_count } }
  end
end
