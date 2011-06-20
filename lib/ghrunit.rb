require "stringio"

# In the future I'd want to try to make this move
# into [Turn](https://github.com/TwP/turn) itself.
#
# For now, just using some internals of `Turn`.
begin
  # Used to colorize stuff
  require "turn/colorize"
  # Used for the tabto stuff
  require "turn/core_ext"
rescue LoadError
  begin
    require 'rubygems'
    # Used to colorize stuff
    require "turn/colorize"
    # Used for the tabto stuff
    require "turn/core_ext"
  end
end

class GHRunit
  include Turn::Colorize

  # Can be initialized with an Xcode `target` and a
  # specified `Configuration`.
  #
  #      GHRunit.new(:target => "Tests")
  #
  # Will start off a test build and run it.
  def initialize(options = {})
    options = default_options.merge(options)
    @target        = options[:target]
    @configuration = options[:configuration]
    @buffer        = StringIO.new
    @error         = StringIO.new

    start_suite!
  end

  def default_options
    {:target => "tests", :configuration => "Debug"}
  end

  # The `Xcode` command line build argument.
  def xcode_command_line_command
    "xcodebuild -target #{@target} -configuration #{@configuration} -sdk iphonesimulator build"
  end

  # This function does all the work.
  def start_suite!
    # Redirect output to ourselves
    $stdout = @buffer
    $stderr = @error

    # PREPARING THE BUILD!
    puts %x{#{xcode_command_line_command}}

    # Giving back output
    $stdout = STDOUT
    @buffer.rewind

    # Parsing and outputting
    until @buffer.eof?
      parse_line(@buffer.readline)
    end
  end

  # This parses the actual the output, we're using some basic
  # regex matching, so pretty brittle at the moment.
  def parse_line(line)
    case line
    when ''
      # Skip blank lines
    when /Test Suite '([a-zA-Z ]*)' started./
      log_suite($1)
    when /^Starting ([a-zA-Z]*)\/([a-zA-Z]*)/
      log_test($1, $2)
    when /^\s(OK|FAIL)\s\((.+)\)/
      log_test_response($1, $2)
    when /Test Suite '([a-zA-Z ]*)' finished./
      # Another hook, but for now skipping
    when /^(Executed(.?)+)$/
      log_summary($1)
    else
      # do nothing
    end
  end

  # ## Log methods

  def log_suite(name)
    puts "Starting for #{name}..."
  end

  def log_test(document, method)
    if document != @document
      puts Turn::Colorize.bold("#{document}").tabto(2)
    end

    @document = document
    @test_method = method
  end

  def log_test_response(response, time)
    colorized = Turn::Colorize.red(response)
    colorized = Turn::Colorize.green(response) if response == "OK"

    method = @test_method.tabto(4)

    puts "#{method} #{colorized} (#{time})"
  end

  def log_summary(summary)
    puts "\n"
    if /(\d) failures/.match(summary)[1] == "0"
      summary.gsub!(/(\d failures?)/, Turn::Colorize.green('\1'))
    else
      summary.gsub!(/(\d failures?)/, Turn::Colorize.red('\1'))
    end
    puts summary
  end
end
