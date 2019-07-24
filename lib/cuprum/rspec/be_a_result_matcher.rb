# frozen_string_literal: true

require 'cuprum/errors/operation_not_called'
require 'cuprum/rspec'

module Cuprum::RSpec
  # Custom matcher that asserts the actual object is a Cuprum result object with
  # the specified properties.
  class BeAResultMatcher
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

    private

    attr_reader :actual, :expected_status

    def actual_is_result?
      actual.respond_to?(:to_cuprum_result)
    end

    def actual_is_uncalled_operation?
      result.error.is_a?(Cuprum::Errors::OperationNotCalled)
    end

    def expected_properties?
      expected_status?
    end

    def expected_status?
      !!expected_status
    end

    def negated_matcher_warning
      "Using `expect().not_to be_a_result#{properties_warning}` risks false" \
      ' positives, since any other result will match.'
    end

    def properties_description
      ary = []
      ary << "with status: #{expected_status.inspect}" if expected_status?

      tools.array.humanize_list(ary)
    end

    def properties_failure_message
      properties_short_message + status_failure_message
    end

    def properties_match?
      status_matches?
    end

    def properties_short_message
      ary = []
      ary << 'status' unless status_matches?

      ", but the #{tools.array.humanize_list(ary)}" \
      " #{tools.integer.pluralize(ary.size, 'did', 'does')} not match:"
    end

    def properties_warning
      ary = []
      ary << 'status' if expected_status?

      return '' if ary.empty?

      message = ".with_#{ary.first}()"

      return message if ary.size == 1

      # :nocov:
      message + ary[1..-1].map { |str| ".and_#{str}()" }.join
      # :nocov:
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
  end
end
