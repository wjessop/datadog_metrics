# Mock statsd class to record data during the specs.
class FakeDatadogMetrics
  attr_accessor :metrics

  delegate :empty?, to: :metrics

  def initialize
    self.metrics = []
  end

  def increment(*arguments)
    metrics << [:increment, *arguments]
  end

  def increment_with_tags(*arguments)
    metrics << [:increment, *arguments]
  end

  def histogram_with_tags(*arguments)
    metrics << [:histogram, *arguments]
  end

  def count_with_tags(*arguments)
    metrics << [:count, *arguments]
  end

  def gauge(*arguments)
    metrics << [:guage, *arguments]
  end

  def timing_with_tags(*arguments)
    metrics << [:timing, *arguments]
  end
end
