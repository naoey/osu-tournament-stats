# frozen_string_literal: true

if ENV.fetch("OTS_OPENSEARCH_ENABLED", false)
  SemanticLogger.add_appender(
    appender:    :opensearch,
    url:         ENV.fetch("OTS_OPENSEARCH_URL"),
    index:       "ots-log",
    data_stream: true
  )
end

