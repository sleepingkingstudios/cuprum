# frozen_string_literal: true

require 'forwardable'

require 'cuprum'
require 'cuprum/errors/multiple_errors'
require 'cuprum/result'

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
  class ResultList < Cuprum::Result
    extend  Forwardable
    include Enumerable

    UNDEFINED = SleepingKingStudios::Tools::UNDEFINED
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
      error:  UNDEFINED,
      status: UNDEFINED,
      value:  UNDEFINED
    )
      @allow_partial = allow_partial
      @results       = normalize_results(results)

      error  = build_error  if error  == UNDEFINED
      status = build_status if status == UNDEFINED
      value  = values       if value  == UNDEFINED

      super(error:, status:, value:)
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

    # @return [Array<Cuprum::Error, nil>] the error, if any, for each result.
    def errors
      @errors ||= results.map(&:error)
    end

    # @return [Array<Symbol>] the status for each result.
    def statuses
      @statuses ||= results.map(&:status)
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
