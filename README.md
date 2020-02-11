# DatadogMetrics

DatadogMetrics provides a convenient wrapper around sending metrics to Datadog in your Ruby application.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'datadog_metrics'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install datadog_metrics

## Usage

For Rails, create an initialiser, eg. `config/initializers/datadog_metrics.rb` containing something like:

```ruby
Rails.configuration.datadog_metrics = if ["development", "test"].include? Rails.env
  require "datadog_metrics/logger"
  DatadogMetrics.new(DatadogLogger.new(Datadog::Statsd.new))
else
  DatadogMetrics.new
end
```

The development/test branch will use the DatadogMetrics built-in logger to log the metrics that would have been sent, rather than logging them to Datadog.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Updating the gem version

To update it, first bump the version appropriately in the `version.rb` file. Afterwards build the gem by running:
```bash
  gem build datadog_metrics.gemspec
```

Then either use the ```rake push``` rake task to push the gem to rubygems.

## Versioning / Changes

DatadogMetrics uses [semantic versioning](https://semver.org/), please respect that when making changes. When you make changes please log these in the CHANGELOG.md file.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/wjessop/datadog_metrics.

## License

MIT, see LICENSE file.
