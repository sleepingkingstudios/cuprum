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
    # @param results [Array<Cuprum::Result>] The wrapped results.
    def initialize(*results, allow_partial: false)
      @allow_partial = allow_partial
      @results       = normalize_results(results)
    end

    # @return [Array<Cuprum::Result>] the wrapped results.
    attr_reader :results
    alias_method :to_a, :results

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

    # @return [Cuprum::Errors::MultipleErrors, nil] the error, if any, for each
    #   result, or nil if none of the results have errors.
    def error
      return @error if @error

      return if errors.compact.empty?

      @error = Cuprum::Errors::MultipleErrors.new(errors: errors)
    end

    # @return [Array<Cuprum::Error, nil>] the error, if any, for each result.
    def errors
      @errors ||= results.map(&:error)
    end

    # @return [Boolean] true if the result status is :failure, otherwise false.
    def failure?
      status == :failure
    end

    # Determines the status of the combined results.
    #
    # By default, returns :success if there are no failing results, i.e. the
    # results array is empty or all of the results are passing. If there is at
    # least one failing result, it instead returns :failure.
    #
    # If the :allow_partial flag is set to true, returns :success if the results
    # array is empty or there is at least one passing result. If there is at
    # least one failing result and no passing results, it instead returns
    # :failure.
    #
    # @return [:success, :failure] the status of the combined results.
    def status
      return @status if @status

      @status = passing_result? ? :success : :failure
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
      Cuprum::Result.new(error: error, status: status, value: value)
    end

    # @return [Array<Object, nil>] the value, if any, for each result.
    def values
      @values ||= results.map(&:value)
    end
    alias_method :value, :values

    private

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
