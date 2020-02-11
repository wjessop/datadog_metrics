RSpec::Matchers.define :have_logged do |expected|
  # The string to display for the expected value.
  # NOTE Regexp#inspect is nicer than Regexp#to_s but we don't want to inspect
  #      the String and show the surrounding quotes.
	expected_string = expected.is_a?(Regexp) ? expected.inspect : expected.to_s

	# Whether the line matches.
	matching_line = lambda do |line|
		case expected
		when String
			line.include? expected
		when Regexp
			line.match expected
		else
			raise 'Must provide a String or Regexp'
		end
	end


  # # Whether the severity matches.
  # # NOTE This matches the conventional Logger format, which has the severity tag
  # #      followed by ' -- :'. (Technically, the logger's progname goes between
  # #      the '--' and the ':', but it is unset for the Rails logger.) If this
  # #      format is changed, it may cause false reports and need to be changed
  # #      here as well.
  # matching_severity = ->(line, severity) { severity ? line.include?("#{severity} -- :") : true }

  match do |actual|
    # # NOTE: Only the new StringIO-backed Logger object will respond to logdev.
    # raise 'Logger has not been faked. Make sure you include the shared context.' \
    #   unless actual.respond_to? :logdev

    # # The logger has a log device which has a device -- this is our StringIO.
    # io = actual.logdev.dev

    # # Writing to the StringIO advances its seek cursor so we must rewind.
    # io.rewind

    # io.each_line.any? do |line|
    #   matching_line.call(line) && matching_severity.call(line, @severity)
    # end
  end

  description { "logs a metric matching #{expected_string}" }

  # # See http://ruby-doc.org/stdlib-2.5.3/libdoc/logger/rdoc/Logger/Severity.html
  # # NOTE The defined? check is needed because of the way this block is
  # #      metaprogrammatically evaluated.
  # SEVERITIES = %i[debug error fatal info unknown warn].freeze unless defined? SEVERITIES

  # chain(:with_severity) do |severity|
  #   raise "unknown severity #{severity.inspect}, severities are #{SEVERITIES.to_sentence}" \
  #     unless SEVERITIES.include? severity

  #   # NOTE The use of a matcher instantiates an object so we can use instance
  #   #      variables to pass information around.
  #   @severity = severity == :unknown ? 'ANY' : severity.to_s.upcase
  # end

  failure_message do |actual|
    message  = 'Expected that DatadogMetrics would have logged a metric'
    # message += " of severity #{@severity}" if @severity
    message += " matching:\n  #{expected_string}"
    message += "\n\nLogged:\n#{actual.logdev.dev.string}"
    message
  end
end
