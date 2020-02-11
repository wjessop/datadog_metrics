# Datadoglogger is designed to be used in Development mode and will log the
# metrics that would have been sent to datadog without the need to run dogstatsd
# locally.
class DatadogLogger
  (Datadog::Statsd.instance_methods - Object.instance_methods).each do |method|
    define_method(method) do |*args, &block|
      Rails.logger.info "Datadog: '#{method}' called on the Datadog logger with args: #{args.inspect}"
      block.call if block
    end
  end

  def initialize(target)
    @target = target
  end
end
