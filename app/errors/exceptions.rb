module Exceptions
  class BeatmapNotFoundError < StandardError; end
  class PlayerNotFoundError < StandardError; end
  class MatchParseFailedError < StandardError; end
end
