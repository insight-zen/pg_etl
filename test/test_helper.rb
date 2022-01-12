# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "pg_etl"

require "minitest/reporters"
require "minitest/autorun"
require "minitest/focus"

Minitest::Reporters.use!(Minitest::Reporters::ProgressReporter.new, ENV, Minitest.backtrace_filter)

module AssertiveTest
  def test(name, &block)
    test_name = "test_#{name.gsub(/\s+/, '_')}".to_sym
    defined = method_defined? test_name
    raise "#{test_name} is already defined in #{self}" if defined
    if block_given?
      define_method(test_name, &block)
    else
      define_method(test_name) do
        flunk "Provide a block to test in #{name}. That will implement the test."
      end
    end
  end
end

MiniTest::Test.extend AssertiveTest
