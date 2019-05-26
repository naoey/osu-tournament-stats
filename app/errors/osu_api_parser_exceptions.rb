module OsuApiParserExceptions
  class MatchParseFailedError < StandardError; end
  class MatchExistsError < StandardError; end
  class PlayerLoadFailedError < StandardError; end
  class BeatmapLoadFailedError < StandardError; end
end
