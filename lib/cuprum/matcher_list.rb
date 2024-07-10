# frozen_string_literal: true

require 'cuprum'

module Cuprum
  # Handles matching a result against an ordered list of matchers.
  #
  # A MatcherList should be used when you have a series of matchers with a
  # defined priority ordering. Within that ordering, the list will check for the
  # most specific matching clause in each of the matchers. A clause matching
  # both the value and error will match first, followed by a clause matching
  # only the result value or error, and finally a clause matching only the
  # result status will match. If none of the matchers have a clause that matches
  # the result, a Cuprum::Matching::NoMatchError will be raised.
  #
  # @example Using A MatcherList
  #   generic_matcher = Cuprum::Matcher.new do
  #     match(:failure) { 'generic failure' }
  #
  #     match(:failure, error: CustomError) { 'custom failure' }
  #   end
  #   specific_matcher = Cuprum::Matcher.new do
  #     match(:failure, error: Cuprum::Error) { 'specific failure' }
  #   end
  #   matcher_list = Cuprum::MatcherList.new(
  #     [
  #       specific_matcher,
  #       generic_matcher
  #     ]
  #   )
  #
  #   # A failure without an error does not match the first matcher, so the
  #   # matcher list continues on to the next matcher in the list.
  #   result = Cuprum::Result.new(status: :failure)
  #   matcher_list.call(result)
  #   #=> 'generic failure'
  #
  #   # A failure with an error matches the first matcher.
  #   error  = Cuprum::Error.new(message: 'Something went wrong.')
  #   result = Cuprum::Result.new(error: error)
  #   matcher_list.call(result)
  #   #=> 'specific failure'
  #
  #   # A failure with an error subclass still matches the first matcher, even
  #   # though the second matcher has a more exact match.
  #   error  = CustomError.new(message: 'The magic smoke is escaping.')
  #   result = Cuprum::Result.new(error: error)
  #   matcher_list.call(result)
  #   #=> 'specific failure'
  class MatcherList
    # @param matchers [Array<Cuprum::Matching>] The matchers to match against a
    #   result, in order of descending priority.
    def initialize(matchers)
      @matchers = matchers
    end

    # @return [Array<Cuprum::Matching>] the matchers to match against a result.
    attr_reader :matchers

    # Finds and executes the best matching clause from the ordered matchers.
    #
    # When given a result, the matcher list will check through each of the
    # matchers in the order they were given for match clauses that match the
    # result. Each matcher is checked for a clause that matches the status,
    # error, and value of the result. If no matching clause is found, the
    # matchers are then checked for a clause matching the status and either the
    # error or value of the result. Finally, if there are still no matching
    # clauses, the matchers are checked for a clause that matches the result
    # status.
    #
    # Once a matching clause is found, that clause is then called with the
    # given result.
    #
    # If none of the matchers have a clause that matches the result, a
    # Cuprum::Matching::NoMatchError will be raised.
    #
    # @param result [Cuprum::Result] The result to match.
    #
    # @raise [Cuprum::Matching::NoMatchError] if none of the matchers match the
    #   given result.
    #
    # @see Cuprum::Matching#call.
    def call(result)
      unless result.respond_to?(:to_cuprum_result)
        raise ArgumentError, 'result must be a Cuprum::Result'
      end

      result  = result.to_cuprum_result
      matcher = matcher_for(result)

      return matcher.call(result) if matcher

      raise Cuprum::Matching::NoMatchError,
        "no match found for #{result.inspect}"
    end

    private

    def error_match?(matcher:, result:)
      matcher.matches?(
        result.status,
        error: result.error&.class
      )
    end

    def exact_match?(matcher:, result:)
      matcher.matches?(
        result.status,
        error: result.error&.class,
        value: result.value&.class
      )
    end

    def find_exact_match(result)
      matchers.find do |matcher|
        exact_match?(matcher:, result:)
      end
    end

    def find_generic_match(result)
      matchers.find do |matcher|
        generic_match?(matcher:, result:)
      end
    end

    def find_partial_match(result)
      matchers.find do |matcher|
        error_match?(matcher:, result:) ||
          value_match?(matcher:, result:)
      end
    end

    def generic_match?(matcher:, result:)
      matcher.matches?(result.status)
    end

    def matcher_for(result)
      find_exact_match(result) ||
        find_partial_match(result) ||
        find_generic_match(result)
    end

    def value_match?(matcher:, result:)
      matcher.matches?(
        result.status,
        value: result.value&.class
      )
    end
  end
end
