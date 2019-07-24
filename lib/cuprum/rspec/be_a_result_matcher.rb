# frozen_string_literal: true

require 'cuprum/errors/operation_not_called'
require 'cuprum/rspec'

module Cuprum::RSpec
  # Custom matcher that asserts the actual object is a Cuprum result object with
  # the specified properties.
  class BeAResultMatcher # rubocop:disable Metrics/ClassLength
    DEFAULT_VALUE = Object.new.freeze
    private_constant :DEFAULT_VALUE

    def initialize
      @expected_value = DEFAULT_VALUE
    end

    # @return [String] a short description of the matcher and expected
    #   properties.
    def description
      message = 'be a Cuprum result'

      return message unless expected_properties?

      "#{message} #{properties_description}"
    end

    # Checks that the given actual object is not a Cuprum result.
    #
    # @param actual [Object] The actual object to match.
    #
    # @return [Boolean] false if the actual object is a result; otherwise true.
    def does_not_match?(actual)
      @actual = actual

      raise ArgumentError, negated_matcher_warning if expected_properties?

      !actual_is_result?
    end

    # @return [String] a summary message describing a failed expectation.
    def failure_message
      message = "expected #{actual.inspect} to #{description}"

      if !actual_is_result?
        message + ', but the object is not a result'
      elsif actual_is_uncalled_operation?
        message + ', but the object is an uncalled operation'
      elsif !properties_match?
        message + properties_failure_message
      else
        # :nocov:
        message
        # :nocov:
      end
    end

    # @return [String] a summary message describing a failed negated
    #   expectation.
    def failure_message_when_negated
      "expected #{actual.inspect} not to #{description}"
    end

    # Checks that the given actual object is a Cuprum result or compatible
    # object and has the specified properties.
    #
    # @param actual [Object] The actual object to match.
    #
    # @return [Boolean] true if the actual object is a result with the expected
    #   properties; otherwise false.
    def matches?(actual)
      @actual = actual

      actual_is_result? && !actual_is_uncalled_operation? && properties_match?
    end

    # Sets a status expectation on the matcher. Calls to #matches? will fail
    # unless the actual object has the specified status.
    #
    # @param status [Symbol] The expected status.
    #
    # @return [BeAResultMatcher] the updated matcher.
    def with_status(status)
      @expected_status = status

      self
    end
    alias_method :and_status, :with_status

    # Sets a value expectation on the matcher. Calls to #matches? will fail
    # unless the actual object has the specified value.
    #
    # @param value [Object] The expected value.
    #
    # @return [BeAResultMatcher] the updated matcher.
    def with_value(value)
      @expected_value = value

      self
    end
    alias_method :and_value, :with_value

    private

    attr_reader \
      :actual,
      :expected_status,
      :expected_value

    def actual_is_result?
      actual.respond_to?(:to_cuprum_result)
    end

    def actual_is_uncalled_operation?
      result.error.is_a?(Cuprum::Errors::OperationNotCalled)
    end

    def compare_items(expected, actual)
      return expected.matches?(actual) if expected.respond_to?(:matches?)

      expected == actual
    end

    def expected_properties?
      expected_value? || expected_status?
    end

    def expected_status?
      !!expected_status
    end

    def expected_value?
      expected_value != DEFAULT_VALUE
    end

    def inspect_expected(expected)
      return expected.description if expected.respond_to?(:description)

      expected.inspect
    end

    def negated_matcher_warning
      "Using `expect().not_to be_a_result#{properties_warning}` risks false" \
      ' positives, since any other result will match.'
    end

    def properties_description
      ary = []
      ary << 'the expected value' if expected_value?
      ary << "status: #{expected_status.inspect}" if expected_status?

      "with #{tools.array.humanize_list(ary)}"
    end

    def properties_failure_message
      properties_short_message + status_failure_message + value_failure_message
    end

    def properties_match?
      status_matches? && value_matches?
    end

    def properties_short_message
      ary = []
      ary << 'status' unless status_matches?
      ary << 'value'  unless value_matches?

      ", but the #{tools.array.humanize_list(ary)}" \
      " #{tools.integer.pluralize(ary.size, 'does', 'do')} not match:"
    end

    def properties_warning
      ary = []
      ary << 'value'  if expected_value?
      ary << 'status' if expected_status?

      return '' if ary.empty?

      message = ".with_#{ary.first}()"

      return message if ary.size == 1

      message + ary[1..-1].map { |str| ".and_#{str}()" }.join
    end

    def result
      @result ||= actual.to_cuprum_result
    end

    def status_failure_message
      return '' if status_matches?

      "\n  expected status: #{expected_status.inspect}" \
      "\n    actual status: #{result.status.inspect}"
    end

    def status_matches?
      return @status_matches unless @status_matches.nil?

      return @status_matches = true unless expected_status?

      @status_matches = result.status == expected_status
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end

    def value_failure_message
      return '' if value_matches?

      "\n   expected value: #{inspect_expected(expected_value)}" \
      "\n     actual value: #{result.value.inspect}"
    end

    def value_matches?
      return @value_matches unless @value_matches.nil?

      return @value_matches = true unless expected_value?

      @value_matches = compare_items(expected_value, result.value)
    end
  end
end
