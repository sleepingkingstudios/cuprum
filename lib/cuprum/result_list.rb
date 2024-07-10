# frozen_string_literal: true

require 'forwardable'

require 'cuprum'
require 'cuprum/errors/multiple_errors'

module Cuprum
  # Collection object that encapsulates a set of Cuprum results.
  #
  # Each Cuprum::ResultList wraps an Array of Cuprum::Result objects, and itself
  # implements the same methods as a Result: #status, #value, #error, and the
  # #success? and #failure? predicates. As such, a Command's #process method can
  # return a ResultList instead of a Result. This is useful for commands that
  # operate on a collection of items, such as a MapCommand or a controller
  # endpoint that performs a bulk operation.
  #
  # @see Cuprum::Result.
  class ResultList
    extend  Forwardable
    include Enumerable

    UNDEFINED = Object.new.freeze
    private_constant :UNDEFINED

    # @!method each
    #   Iterates over the results.
    #
    #   @overload each()
    #     @return [Enumerator] an enumerator over the results.
    #
    #   @overload each(&block)
    #     Yields each result to the block.
    #
    #     @yieldparam result [Cuprum::Result] the yielded result.

    # @param allow_partial [true, false] If true, allows for some failing
    #   results as long as there is at least one passing result. Defaults to
    #   false.
    # @param error [Cuprum::Error] If given, sets the error for the result list
    #   to the specified error object.
    # @param results [Array<Cuprum::Result>] The wrapped results.
    # @param status [:success, :failure] If given, sets the status of the result
    #   list to the specified value.
    # @param value [Object] The value of the result. Defaults to the mapped
    #   values of the results.
    def initialize(
      *results,
      allow_partial: false,
      error: UNDEFINED,
      status: UNDEFINED,
      value: UNDEFINED
    )
      @allow_partial = allow_partial
      @results       = normalize_results(results)
      @error         = error  == UNDEFINED ? build_error  : error
      @status        = status == UNDEFINED ? build_status : status
      @value         = value  == UNDEFINED ? values : value
    end

    # @return [Array<Cuprum::Result>] the wrapped results.
    attr_reader :results
    alias_method :to_a, :results

    # Returns the error for the result list.
    #
    # If the result list was initialized with an error, returns that error.
    #
    # If any of the results have errors, aggregates the result errors into a
    # Cuprum::MultipleErrors object.
    #
    # If none of the results have errors, returns nil.
    #
    # @return [Cuprum::Errors::MultipleErrors, Cuprum::Error, nil] the error for
    #   the result list.
    attr_reader :error

    # Determines the status of the combined results.
    #
    # If the result list was initialize with a status, returns that status.
    #
    # If there are no failing results, i.e. the results array is empty or all of
    # the results are passing, returns :success.
    #
    # If there is at least one failing result, it instead returns :failure.
    #
    # If the :allow_partial flag is set to true, returns :success if the results
    # array is empty or there is at least one passing result. If there is at
    # least one failing result and no passing results, it instead returns
    # :failure.
    #
    # @return [:success, :failure] the status of the combined results.
    attr_reader :status

    # @return [Object] The value of the result. Defaults to the mapped values of
    #   the results.
    attr_reader :value

    def_delegators :@results, :each

    # @return [true, false] true if the other object is a ResultList with
    #   matching results and options; otherwise false.
    def ==(other)
      other.is_a?(ResultList) &&
        results        == other.results &&
        allow_partial? == other.allow_partial?
    end

    # @return [true, false] if true, allows for some failing results as long as
    #   there is at least one passing result. Defaults to false.
    #
    # @see #status
    # @see #to_cuprum_result
    def allow_partial?
      @allow_partial
    end

    # @return [Array<Cuprum::Error, nil>] the error, if any, for each result.
    def errors
      @errors ||= results.map(&:error)
    end

    # @return [Boolean] true if the result status is :failure, otherwise false.
    def failure?
      status == :failure
    end

    # @return [Array<Symbol>] the status for each result.
    def statuses
      @statuses ||= results.map(&:status)
    end

    # @return [Boolean] true if the result status is :success, otherwise false.
    def success?
      status == :success
    end

    # Converts the result list to a Cuprum::Result.
    #
    # @return [Cuprum::Result] the converted result.
    #
    # @see #error
    # @see #status
    # @see #value
    def to_cuprum_result
      Cuprum::Result.new(error:, status:, value:)
    end

    # @return [Array<Object, nil>] the value, if any, for each result.
    def values
      @values ||= results.map(&:value)
    end

    private

    def build_error
      return if errors.compact.empty?

      Cuprum::Errors::MultipleErrors.new(errors:)
    end

    def build_status
      passing_result? ? :success : :failure
    end

    def normalize_results(results)
      results.map do |obj|
        next obj if obj.is_a?(Cuprum::ResultList)

        next obj.to_cuprum_result if obj.respond_to?(:to_cuprum_result)

        raise ArgumentError,
          "invalid result: #{obj.inspect} does not respond to #to_cuprum_result"
      end
    end

    def passing_result?
      return true if results.empty?

      if allow_partial?
        results.any?(&:success?)
      else
        results.all?(&:success?)
      end
    end
  end
end
