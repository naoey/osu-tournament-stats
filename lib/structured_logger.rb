class StructuredLogger
  PLACEHOLDER = '{}'

  def initialize(logger = Rails.logger)
    @logger = logger
  end

  Logger::Severity.constants.each do |level|
    severity = Logger::Severity.const_get(level)

    define_method(level.downcase) do |message = nil, *args, &block|
      if message.is_a?(String) && args.any?
        msg = interpolate(message, args)
        @logger.add(severity, msg, nil, &block)
      else
        @logger.add(severity, message, nil, &block)
      end
    end
  end

  def interpolate(message, args)
    parts = message.split(PLACEHOLDER, args.length + 1)
    result = parts.zip(args.map { |a| safe_inspect(a) }).flatten.compact.join

    leftover_args = args[parts.size - 1..] || []
    result += " " + leftover_args.map { |a| safe_inspect(a) }.join(" ") if leftover_args.any?

    result
  end

  def safe_inspect(obj)
    obj.inspect
  rescue StandardError
    "<Uninspectable #{obj.class}>"
  end

  def method_missing(method, *args, &block)
    @logger.respond_to?(method) ? @logger.public_send(method, *args, &block) : super
  end

  def respond_to_missing?(method, include_private = false)
    @logger.respond_to?(method, include_private) || super
  end
end
