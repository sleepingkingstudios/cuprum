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
      'be a Cuprum result'
    end

    # Checks that the given actual object is not a Cuprum result.
    #
    # @return [Boolean] false if the actual object is a result; otherwise true.
    def does_not_match?(actual)
      @actual = actual

      !actual_is_result?
    end

    # @return [String] a summary message describing a failed expectation.
    def failure_message
      "expected #{actual.inspect} to #{description}"
    end

    # @return [String] a summary message describing a failed negated
    #   expectation.
    def failure_message_when_negated
      "expected #{actual.inspect} not to #{description}"
    end

    # Checks that the given actual object is a Cuprum result or compatible
    # object and has the specified properties.
    #
    # @return [Boolean] true if the actual object is a result with the expected
    #   properties; otherwise false.
    def matches?(actual)
      @actual = actual

      actual_is_result? && !actual_is_uncalled_operation?
    end

    private

    attr_reader :actual

    def actual_is_result?
      actual.respond_to?(:to_cuprum_result)
    end

    def actual_is_uncalled_operation?
      actual.to_cuprum_result.error.is_a?(Cuprum::Errors::OperationNotCalled)
    end
  end
end
