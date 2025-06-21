begin
  require "opensearch"
rescue LoadError
  raise LoadError,
        'Gem opensearch-ruby is required for logging to Elasticsearch. Please add the gem "elasticsearch" to your Gemfile.'
end

require "date"

##
# Copy of Semantic Logger's built in Elasticsearch appender tweaked to use an OpenSearch client instead.
module SemanticLogger
  module Appender
    class Opensearch < SemanticLogger::Subscriber
      attr_accessor :url, :index, :date_pattern, :type, :client, :flush_interval, :timeout_interval, :batch_size,
                    :elasticsearch_args
      def initialize(url: "http://localhost:9200",
                     index: "semantic_logger",
                     date_pattern: "%Y.%m.%d",
                     type: "log",
                     level: nil,
                     formatter: nil,
                     filter: nil,
                     application: nil,
                     environment: nil,
                     host: nil,
                     data_stream: false,
                     **elasticsearch_args,
                     &block)

        @url                         = url
        @index                       = index
        @date_pattern                = date_pattern
        @type                        = type
        @elasticsearch_args          = elasticsearch_args.dup
        @elasticsearch_args[:url]    = url if url && !elasticsearch_args[:hosts]
        @elasticsearch_args[:logger] = logger
        @data_stream                 = data_stream

        super(level: level, formatter: formatter, filter: filter, application: application, environment: environment, host: host, metrics: false, &block)
        reopen
      end

      def reopen
        @client = ::OpenSearch::Client.new(
          url: "http://localhost:9200",
          retry_on_failure: 5,
          request_timeout: 120,
          log: false
        )

        client.cluster.health
      end

      # Log to the index for today
      def log(log)
        bulk_payload = formatter.call(log, self)
        write_to_elasticsearch([bulk_index(log), bulk_payload])
        true
      end

      def batch(logs)
        messages = []
        logs.each do |log|
          messages << bulk_index(log) << formatter.call(log, self)
        end

        write_to_elasticsearch(messages)
        true
      end

      private

      def write_to_elasticsearch(messages)
        bulk_result =
          if @data_stream
            @client.bulk(index: index, body: messages)
          else
            @client.bulk(body: messages)
          end

        return unless bulk_result["errors"]

        failed = bulk_result["items"].reject { |x| x["status"] == 201 }
        logger.error("ElasticSearch: Write failed. Messages discarded. : #{failed}")
      end

      def bulk_index(log)
        expanded_index_name = log.time.strftime("#{index}-#{date_pattern}")
        return {"create" => {}} if @data_stream

        bulk_index = {"index" => {"_index" => expanded_index_name}}
        bulk_index
      end

      def default_formatter
        time_key = @data_stream ? "@timestamp" : :timestamp
        SemanticLogger::Formatters::Raw.new(time_format: :iso_8601, time_key: time_key)
      end

      def version_supports_type?
        Gem::Version.new(::Elasticsearch::VERSION) < Gem::Version.new(7)
      end
    end
  end
end

if Rails.env.production? || ENV.fetch("OTS_ENABLE_OPENSEARCH", false)
  SemanticLogger.add_appender(
    appender: SemanticLogger::Appender::Opensearch.new(index: 'ots'),
  )
end
