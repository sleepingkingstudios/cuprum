# frozen_string_literal: true

require 'cuprum'
require 'cuprum/matching'

module Cuprum
  # Provides result matching based on result status, error, and value.
  #
  # First, define match clauses using the .match DSL. Each match clause has a
  # status and optionally a value class and/or error class. A result will only
  # match the clause if the result status is the same as the clause's status.
  # If the clause sets a value class, then the result value must be an instance
  # of that class (or an instance of a subclass). If the clause sets an error
  # class, then the result error must be an instance of that class (or an
  # instance of a subclass).
  #
  # Once the matcher defines one or more match clauses, call #call with a result
  # to match the result. The matcher will determine the best match with the same
  # status (value and error match the result, only value or error match, or just
  # status matches) and then call the match clause with the result. If no match
  # clauses match the result, the matcher will instead raise a
  # Cuprum::Matching::NoMatchError.
  #
  # @example Matching A Status
  #   matcher = Cuprum::Matcher.new do
  #     match(:failure) { 'Something went wrong' }
  #
  #     match(:success) { 'Ok' }
  #   end
  #
  #   matcher.call(Cuprum::Result.new(status: :failure))
  #   #=> 'Something went wrong'
  #
  #   matcher.call(Cuprum::Result.new(status: :success))
  #   #=> 'Ok'
  #
  # @example Matching An Error
  #   matcher = Cuprum::Matcher.new do
  #     match(:failure) { 'Something went wrong' }
  #
  #     match(:failure, error: CustomError) { |result| result.error.message }
  #
  #     match(:success) { 'Ok' }
  #   end
  #
  #   matcher.call(Cuprum::Result.new(status: :failure))
  #   #=> 'Something went wrong'
  #
  #   error = CustomError.new(message: 'The magic smoke is escaping.')
  #   matcher.call(Cuprum::Result.new(error: error))
  #   #=> 'The magic smoke is escaping.'
  #
  # @example Using A Match Context
  #   context = Struct.new(:name).new('programs')
  #   matcher = Cuprum::Matcher.new(context) do
  #     match(:failure) { 'Something went wrong' }
  #
  #     match(:success) { "Greetings, #{name}!" }
  #   end
  #
  #   matcher.call(Cuprum::Result.new(status: :success)
  #   #=> 'Greetings, programs!'
  class Matcher
    include Cuprum::Matching

    # @param match_context [Object] the execution context for a matching clause.
    #
    # @yield Executes the block in the context of the singleton class. This is
    #   used to define match clauses when instantiating a Matcher instance.
    def initialize(match_context = nil, &block)
      @match_context = match_context

      singleton_class.instance_exec(&block) if block_given?
    end

    # Returns a copy of the matcher with the given execution context.
    #
    # @param match_context [Object] the execution context for a matching clause.
    #
    # @return [Cuprum::Matcher] the copied matcher.
    def with_context(match_context)
      clone.tap { |copy| copy.match_context = match_context }
    end
    alias_method :using_context, :with_context

    protected

    attr_writer :match_context
  end
end
