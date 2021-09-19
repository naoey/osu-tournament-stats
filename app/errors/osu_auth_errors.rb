module OsuAuthErrors
  class OsuAuthError < StandardError; end

  class InvalidOsuUserError < OsuAuthError; end

  class TimeoutError < OsuAuthError; end

  class UnauthorisedError < OsuAuthError; end
end
