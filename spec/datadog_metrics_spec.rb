RSpec.describe DatadogMetrics do
  it "has a version number" do
    expect(DatadogMetrics::VERSION).not_to be nil
  end

  context "when tracking time" do
    let(:dm) { DatadogMetrics.new }

    describe ".time" do
      it "calls endpoint.time with stat and yields block" do
        expect { |b| dm.time('some.test.metric', {}, &b) }.to yield_control
      end
    end

    describe ".timing" do
      it "calls endpoint.timing with stat and yields block" do
        expect(dm.endpoint).to receive(:timing).with('some.test.metric', 123, tags: ['foo:bar'])

        dm.timing('some.test.metric', 123, tags: ['foo:bar'])
      end
    end
  end

  context "when instantiated with a nil endpoint" do
    let(:dm) { DatadogMetrics.new(nil) }

    describe '.new' do
      subject { dm.endpoint }
      it { should be_nil }
    end
  end

  context 'when instantiated with no arguments' do
    let(:dm) { DatadogMetrics.new }

    describe '.new' do
      it { should be_an_instance_of DatadogMetrics }
    end

    describe '.endpoint' do
      subject { dm.endpoint }
      it { should be_an_instance_of Datadog::Statsd }
    end
  end

  context 'when passed a custom reporter class' do
    let(:dm) { DatadogMetrics.new }

    describe '.new' do
      it { should be_an_instance_of DatadogMetrics }
    end

    describe '.endpoint' do
      subject { dm.endpoint }
      it { should be_an_instance_of Datadog::Statsd }
    end
  end

  context 'when incrementing' do
    let(:dm) { DatadogMetrics.new }
    let(:statsd) { double('statsd') }

    describe '.increment' do
      it 'calls endpoint.increment with no tags' do
        expect(dm.endpoint).to(receive(:increment).with('some.test.metric', tags: [])).once

        dm.increment('some.test.metric')
      end

      it 'can provide tags as an array' do
        expect(dm.endpoint).to(receive(:increment).with('some.test.metric', tags: ['foo:1'])).once

        dm.increment('some.test.metric', tags: ['foo:1'])
      end

      it 'can provide tags as a hash' do
        expect(dm.endpoint).to(receive(:increment).with('some.test.metric', tags: ['foo:1'])).once

        dm.increment('some.test.metric', tags: { foo: 1 })
      end

      it 'can merge with default tags' do
        expect(described_class).to receive(:default_tags).and_return(
          'foo' => 1,
          'bar' => 2
        )

        expect(dm.endpoint).to(receive(:increment).with('some.test.metric', tags: ['foo:3', 'bar:2', 'baz:4']))

        dm.increment('some.test.metric', tags: ['foo:3', 'baz:4'])
      end
    end

    describe '.increment_with_tags' do
      it 'calls endpoint.increment with tags' do
        allow(dm.endpoint).to receive(:increment) { statsd }
        expect(dm.endpoint).to(receive(:increment).with(
          'some.test.metric',
          :tags => ['sometag']
        )).once
        dm.increment_with_tags('some.test.metric', ['sometag'])
      end
    end
  end

  context 'when decrementing' do
    let(:dm) { DatadogMetrics.new }
    let(:statsd) { double('statsd') }

    describe '.decrement' do
      it 'calls endpoint.decrement with no tags' do
        allow(dm.endpoint).to receive(:decrement) { statsd }
        expect(dm.endpoint).to(receive(:decrement).with('some.test.metric', tags: [])).once
        dm.decrement('some.test.metric')
      end
    end
  end

  context 'when logging a histogram' do
    let(:dm) { DatadogMetrics.new }
    let(:statsd) { double('statsd') }

    describe '.histogram_with_tags' do
      it 'calls endpoint.histogram with tags' do
        allow(dm.endpoint).to receive(:histogram) { statsd }
        expect(dm.endpoint).to(receive(:histogram).with(
          'some.test.metric',
          10,
          :tags => ['sometag']
        )).once
        dm.histogram_with_tags('some.test.metric', 10, ['sometag'])
      end
    end
  end

  context 'when logging an event' do
    let(:dm) { DatadogMetrics.new }
    let(:statsd) { double('statsd') }

    describe '.event' do
      it 'calls endpoint.event with tags' do
        allow(dm.endpoint).to receive(:event) { statsd }
        expect(dm.endpoint).to(receive(:event).with(
          'Some Event',
          'Details about that event',
          :tags => ['sometag']
        )).once
        dm.event('Some Event', 'Details about that event', tags: ['sometag'])
      end
    end
  end
end
