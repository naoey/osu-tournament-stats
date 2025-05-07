require 'semantic_logger'

class StructuredFormatter < SemanticLogger::Formatters::Color
  PLACEHOLDER = '{}'

  def message
    return log.message if log.payload.nil?

    interpolate_named_placeholders(log.message, log.payload)
  end

  def payload
    log.payload&.map { |k, v| [k, self.safe_inspect(v)] }.to_s
  end

  def interpolate_named_placeholders(message, payload)
    message.gsub(/\{(\w+)\}/) do |_|
      key = Regexp.last_match(1).to_sym
      if payload.key?(key)
        self.safe_inspect(payload[key])
      else
        "{#{key}}"
      end
    end
  end

  def safe_inspect(obj)
    obj.inspect
  rescue StandardError
    "<Uninspectable #{obj.class}>"
  end
end
