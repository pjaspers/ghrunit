require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'
require 'shoulda'
require 'mocha'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'ghrunit'

class Test::Unit::TestCase

  def any_ghrunit
    GHRunit.any_instance
  end

  def test_output_file
    File.new(File.join(File.dirname(__FILE__), "build_output.txt"))
  end
end
