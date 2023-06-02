# frozen_string_literal: true

require 'cuprum/errors/operation_not_called'
require 'cuprum/rspec'

module Cuprum::RSpec
  # Asserts the actual object is a result object with the specified properties.
  #
  # If initialized with a class, the matcher will assert that the actual object
  # is an instance of that class. This can be useful for asserting that the
  # result is an instance of a result subclass. If no class is given, the
  # matcher asserts that the result is an object responding to
  # #to_cuprum_result.
  #
  # The matcher also defines fluent methods for asserting on the result's
  # properties:
  #
  # - The #with_value method asserts that the result has the specified value.
  #   Also aliased as #and_value.
  # - The #with_error method asserts that the result has the specified error.
  #   Also aliased as #and_error.
  # - The #with_status method asserts that the result has the specified status.
  #   Also aliased as #and_status.
  #
  # Generally speaking, you should use the #be_a_result, #be_a_passing_result,
  # and #be_a_failing_result macros, rather than instantiating a
  # BeAResultMatcher directly.
  #
  # @example Matching Any Result
  #   # Or use expect().to be_a_result
  #   matcher = Cuprum::RSpec::BeAResultMatcher.new
  #
  #   matcher.matches?(nil)                #=> false
  #   matcher.matches?(Cuprum::Result.new) #=> true
  #
  # @example Matching A Result Status
  #   # Or use expect().to be_a_passing_result
  #   matcher = Cuprum::RSpec::BeAResultMatcher.new.with_status(:success)
  #
  #   matcher.matches?(Cuprum::Result.new(status: :failure)) #=> false
  #   matcher.matches?(Cuprum::Result.new(status: :success)) #=> false
  #
  # @example Matching A Result Value
  #   matcher = Cuprum::RSpec::BeAResultMatcher.new.with_value({ ok: true })
  #
  #   matcher.matches?(Cuprum::Result.new(value: { ok: false })) #=> false
  #   matcher.matches?(Cuprum::Result.new(value: { ok: true }))  #=> true
  #
  # @example Matching A Result Error
  #   error   = Cuprum::Error.new(message: 'Something went wrong')
  #   matcher = Cuprum::RSpec::BeAResultMatcher.new.with_error(error)
  #
  #   other_error = Cuprum::Error.new(message: 'Oh no')
  #   matcher.matches?(Cuprum::Result.new(error: other_error) #=> false
  #   matcher.matches?(Cuprum::Result.new(error: error)       #=> true
  #
  # @example Matching A Result Class
  #   matcher = Cuprum::RSpec::BeAResultMatcher.new(CustomResult)
  #
  #   matcher.matches?(Cuprum::Result.new) #=> false
  #   matcher.matches?(CustomResult.new)   #=> true
  #
  # @example Matching Multiple Properties
  #   matcher =
  #     Cuprum::RSpec::BeAResultMatcher
  #     .with_status(:failure)
  #     .and_value({ ok: false })
  #     .and_error(Cuprum::Error.new(message: 'Something went wrong'))
  class BeAResultMatcher # rubocop:disable Metrics/ClassLength
    DEFAULT_VALUE = Object.new.freeze
    private_constant :DEFAULT_VALUE

    RSPEC_MATCHER_METHODS = %i[description failure_message matches?].freeze
    private_constant :RSPEC_MATCHER_METHODS

    # @param expected_class [Class] the expected class of result. Defaults to
    #   Cuprum::Result.
    def initialize(expected_class = nil)
      @expected_class = expected_class
      @expected_error = DEFAULT_VALUE
      @expected_value = DEFAULT_VALUE
    end

    # @return [Class] the expected class of result.
    attr_reader :expected_class

    # @return [String] a short description of the matcher and expected
    #   properties.
    def description
      message =
        if expected_class
          "be an instance of #{expected_class}"
        else
          'be a Cuprum result'
        end

      return message unless expected_properties?

      "#{message} #{properties_description}"
    end

    # Checks that the given actual object is not a Cuprum result.
    #
    # @param actual [Object] the actual object to match.
    #
    # @return [Boolean] false if the actual object is a result; otherwise true.
    def does_not_match?(actual)
      @actual = actual

      raise ArgumentError, negated_matcher_warning if expected_properties?

      !actual_is_result?
    end

    # @return [String] a summary message describing a failed expectation.
    def failure_message # rubocop:disable Metrics/MethodLength
      message = "expected #{actual.inspect} to #{description}"

      if !actual_is_result? && expected_class
        "#{message}, but the object is not an instance of #{expected_class}"
      elsif !actual_is_result?
        "#{message}, but the object is not a result"
      elsif actual_is_uncalled_operation?
        "#{message}, but the object is an uncalled operation"
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

    # Sets an error expectation on the matcher. Calls to #matches? will fail
    # unless the actual object has the specified error.
    #
    # @param error [Cuprum::Error, Object] The expected error.
    #
    # @return [BeAResultMatcher] the updated matcher.
    def with_error(error)
      @expected_error = error

      self
    end
    alias_method :and_error, :with_error

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
      :expected_error,
      :expected_status,
      :expected_value

    def actual_is_result?
      return false unless actual.respond_to?(:to_cuprum_result)

      return true unless expected_class

      actual.to_cuprum_result.is_a?(expected_class)
    end

    def actual_is_uncalled_operation?
      result.error.is_a?(Cuprum::Errors::OperationNotCalled)
    end

    def compare_items(expected, actual)
      return expected.matches?(actual) if expected.respond_to?(:matches?)

      expected == actual
    end

    def error_failure_message
      return '' if error_matches?

      "\n   expected error: #{inspect_expected(expected_error)}" \
        "\n     actual error: #{result.error.inspect}"
    end

    def error_matches?
      return @error_matches unless @error_matches.nil?

      return @error_matches = true unless expected_error?

      @error_matches = compare_items(expected_error, result.error)
    end

    def expected_properties?
      (expected_error? && !expected_error.nil?) ||
        expected_status? ||
        expected_value?
    end

    def expected_error?
      expected_error != DEFAULT_VALUE
    end

    def expected_status?
      !!expected_status
    end

    def expected_value?
      expected_value != DEFAULT_VALUE
    end

    def inspect_expected(expected)
      return expected.description if rspec_matcher?(expected)

      expected.inspect
    end

    def negated_matcher_warning
      "Using `expect().not_to be_a_result#{properties_warning}` risks false" \
        ' positives, since any other result will match.'
    end

    # rubocop:disable Metrics/AbcSize
    def properties_description
      msg = ''
      ary = []
      ary << 'value' if expected_value?
      ary << 'error' if expected_error? && !expected_error.nil?

      unless ary.empty?
        msg = "with the expected #{tools.array_tools.humanize_list(ary)}"
      end

      return msg unless expected_status?

      return "with status: #{expected_status.inspect}" if msg.empty?

      msg + " and status: #{expected_status.inspect}"
    end
    # rubocop:enable Metrics/AbcSize

    def properties_failure_message
      properties_short_message +
        status_failure_message +
        value_failure_message +
        error_failure_message
    end

    def properties_match?
      error_matches? && status_matches? && value_matches?
    end

    def properties_short_message
      ary = []
      ary << 'status' unless status_matches?
      ary << 'value'  unless value_matches?
      ary << 'error'  unless error_matches?

      ", but the #{tools.array_tools.humanize_list(ary)}" \
        " #{tools.integer_tools.pluralize(ary.size, 'does', 'do')} not match:"
    end

    def properties_warning
      ary = []
      ary << 'value'  if expected_value?
      ary << 'status' if expected_status?
      ary << 'error'  if expected_error?

      return '' if ary.empty?

      message = ".with_#{ary.first}()"

      return message if ary.size == 1

      message + ary[1..].map { |str| ".and_#{str}()" }.join
    end

    def result
      @result ||= actual.to_cuprum_result
    end

    def rspec_matcher?(value)
      RSPEC_MATCHER_METHODS.all? do |method_name|
        value.respond_to?(method_name)
      end
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
