require "datadog_metrics/version"

require 'datadog/statsd'

# The default endpoint is the local dogstatsd agent which we can
# talk to using the ruby client:
#
# https://github.com/DataDog/dogstatsd-ruby
#
# In development we will pass an object that just logs what it
# would have reported to DataDog to the local log file, and in
# test we pass an object we can test with.

class DatadogMetrics
  class << self
    def default_tags=(tags)
      @default_tags = tags.transform_keys(&:to_s).freeze
    end

    def default_tags
      @default_tags ||= {}
    end
  end

  attr_reader :endpoint

  def initialize(endpoint = Datadog::Statsd.new(ENV.fetch("STATS_HOST", "localhost"), 8125))
    @endpoint = endpoint
  end

  def time(stat, opt={}, &block)
    opt[:tags] = format_tags(opt[:tags]) if opt.key?(:tags)

    @endpoint.time(stat, opt) do
      yield
    end
  end

  def timing(metric, ms, tags: {})
    @endpoint.timing(metric, ms, tags: format_tags(tags))
  end

  def increment(metric, tags: {})
    @endpoint.increment(metric, tags: format_tags(tags))
  end

  def decrement(metric, tags: {})
    @endpoint.decrement(metric, tags: format_tags(tags))
  end

  def count(metric, count, tags: {})
    @endpoint.count(metric, count, tags: format_tags(tags))
  end

  def timing_with_tags(metric, ms, tags)
    @endpoint.timing(metric, ms, tags: format_tags(tags))
  end

  def increment_with_tags(metric, tags)
    @endpoint.increment(metric, tags: format_tags(tags))
  end

  def count_with_tags(metric, count, tags: {})
    @endpoint.count(metric, count, tags: format_tags(tags))
  end

  def gauge(metric, value, tags=[], sample_rate=1, **opts)
    tags = opts[:tags] if opts.key?(:tags)
    @endpoint.gauge(metric, value, tags: format_tags(tags), sample_rate: sample_rate)
  end

  def histogram(metric, value, tags: {})
    @endpoint.histogram(metric, value, tags: format_tags(tags))
  end

  def histogram_with_tags(metric, value, tags)
    @endpoint.histogram(metric, value, tags: format_tags(tags))
  end

  def event(metric, value, tags: {})
    @endpoint.event(metric, value, tags: format_tags(tags))
  end

  def batch
    @endpoint.batch(&proc { yield(endpoint)})
  end

  private

  def format_tags(tags)
    return [] if tags.nil?

    if tags.is_a?(Array)
      tags = tags.each_with_object({}) do |tag, hash|
        key, rest = tag.split(':', 2)
        hash[key] = rest
      end
    end

    self.class.default_tags.
      merge(tags).
      map { |key, value| [key, value].compact.join(':') }
  end
end
