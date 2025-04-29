module ApplicationHelper

  class Notifications
    include SemanticLogger::Loggable

    def self.notify(topic, payload)
      begin
        ActiveSupport::Notifications.instrument(topic, payload)
      rescue StandardError => e
        logger.error("Notification handler error", e)
      end
    end

    def self.subscribe(topic, &block)
      ActiveSupport::Notifications.subscribe(topic) do |event|
        block.call(event.payload)
      end
    end
  end
end
