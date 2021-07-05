# frozen_string_literal: true

require 'cuprum'

module Cuprum
  # Implements result matching based on result status, error, and value.
  #
  # @see Cuprum::Matcher.
  module Matching
    autoload :MatchClause, 'cuprum/matching/match_clause'

    # Class methods extend-ed into a class when the module is included.
    module ClassMethods
      # Defines a match clause for the matcher.
      #
      # @param status [Symbol] The status to match. The clause will match a
      #   result only if the result has the same status as the match clause.
      # @param error [Class] The type of error to match. If given, the clause
      #   will match a result only if the result error is an instance of the
      #   given class, or an instance of a subclass.
      # @param value [Class] The type of value to match. If given, the clause
      #   will match a result only if the result value is an instance of the
      #   given class, or an instance of a subclass.
      #
      # @yield The code to execute on a successful match.
      # @yieldparam result [Cuprum::Result] The matched result.
      def match(status, error: nil, value: nil, &block)
        validate_status!(status)
        validate_error!(error)
        validate_value!(value)

        clause  = MatchClause.new(block, error, status, value)
        clauses = match_clauses[status]
        index   = clauses.bsearch_index { |item| clause <= item } || -1

        # Clauses are sorted from most specific to least specific.
        clauses.insert(index, clause)
      end

      # @private
      def match_result(result:)
        status_clauses(result.status).find do |clause|
          clause.matches_result?(result: result)
        end
      end

      # @private
      def matches_result?(result:)
        status_clauses(result.status).reverse_each.any? do |clause|
          clause.matches_result?(result: result)
        end
      end

      # @private
      def matches_status?(error:, status:, value:)
        status_clauses(status).reverse_each.any? do |clause|
          clause.matches_details?(error: error, value: value)
        end
      end

      protected

      def match_clauses
        @match_clauses ||= Hash.new { |hsh, key| hsh[key] = [] }
      end

      private

      def status_clauses(status)
        ancestors
          .select { |ancestor| ancestor < Cuprum::Matching }
          .map { |ancestor| ancestor.match_clauses[status] }
          .reduce([], &:concat)
          .sort
      end

      def validate_error!(error)
        return if error.nil? || error.is_a?(Module)

        raise ArgumentError,
          'error must be a Class or Module',
          caller(1..-1)
      end

      def validate_status!(status)
        if status.nil? || status.to_s.empty?
          raise ArgumentError, "status can't be blank", caller(1..-1)
        end

        return if status.is_a?(Symbol)

        raise ArgumentError, 'status must be a Symbol', caller(1..-1)
      end

      def validate_value!(value)
        return if value.nil? || value.is_a?(Module)

        raise ArgumentError,
          'value must be a Class or Module',
          caller(1..-1)
      end
    end

    # Exception raised when the matcher does not match a result.
    class NoMatchError < StandardError; end

    class << self
      private

      def included(other)
        super

        other.extend(ClassMethods)
      end
    end

    # @return [Object, nil] the execution context for a matching clause.
    attr_reader :match_context

    # Finds the match clause matching the result and calls the stored block.
    #
    # Match clauses are defined using the .match DSL. When a result is matched,
    # the defined clauses matching the result status are checked in descending
    # order of specificity:
    #
    # - Clauses that expect both a value and an error.
    # - Clauses that expect a value.
    # - Clauses that expect an error.
    # - Clauses that do not expect a value or an error.
    #
    # If there are multiple clauses that expect a value or an error, they are
    # sorted by inheritance - a clause with a subclass value or error is checked
    # before the clause with the parent class.
    #
    # Using that ordering, each potential clause is checked for a match with the
    # result. If the clause defines a value, then the result will match the
    # clause only if the result value is an instance of the expected value (or
    # an instance of a subclass). Likewise, if the clause defines an error, then
    # the result will match the clause only if the result error is an instance
    # of the expected error class (or an instance of a subclass). Clauses that
    # do not define either a value nor an error will match with any result with
    # the same status, but as the least specific are always matched last.
    #
    # Matchers can also inherit clauses from a parent class or from an included
    # module. Inherited or included clauses are checked after clauses defined on
    # the matcher itself, so the matcher can override generic matches with more
    # specific functionality.
    #
    # Finally, once the most specific matching clause is found, #call will
    # call the block used to define the clause. If the block takes at least one
    # argument, the result will be passed to the block; otherwise, it will be
    # called with no parameters. If there is no clause matching the result,
    # #call will instead raise a Cuprum::Matching::NoMatchError.
    #
    # The match clause is executed in the context of the matcher object. This
    # allows instance methods defined for the matcher to be called as part of
    # the match clause block. If the matcher defines a non-nil
    # #matching_context, the block is instead executed in the context of the
    # matching_context using #instance_exec.
    #
    # @param result [Cuprum::Result] The result to match.
    #
    # @return [Object] the value returned by the stored block.
    #
    # @raise [NoMatchError] if there is no clause matching the result.
    #
    # @see ClassMethods::match
    # @see #match_context
    def call(result)
      unless result.respond_to?(:to_cuprum_result)
        raise ArgumentError, 'result must be a Cuprum::Result'
      end

      result = result.to_cuprum_result
      clause = singleton_class.match_result(result: result)

      raise NoMatchError, "no match found for #{result.inspect}" if clause.nil?

      call_match(block: clause.block, result: result)
    end

    # @return [Boolean] true if an execution context is defined for a matching
    #   clause; otherwise false.
    def match_context?
      !match_context.nil?
    end

    # @overload matches?(result)
    #   Checks if the matcher has any match clauses that match the given result.
    #
    #   @param result [Cuprum::Result] The result to match.
    #
    #   @return [Boolean] true if the matcher has at least one match clause that
    #     matches the result; otherwise false.
    #
    # @overload matches?(status, error: nil, value: nil)
    #   Checks if the matcher has any clauses matching the status and details.
    #
    #   @param status [Symbol] The status to match.
    #   @param error [Class, nil] The class of error to match, if any.
    #   @param value [Class, nil] The class of value to match, if any.
    #
    #   @return [Boolean] true if the matcher has at least one match clause that
    #     matches the status and details; otherwise false.
    def matches?(result_or_status, error: nil, value: nil) # rubocop:disable Metrics/MethodLength
      if result_or_status.respond_to?(:to_cuprum_result)
        raise ArgumentError, 'error defined by result' unless error.nil?
        raise ArgumentError, 'value defined by result' unless value.nil?

        return singleton_class.matches_result?(
          result: result_or_status.to_cuprum_result
        )
      elsif result_or_status.is_a?(Symbol)
        return singleton_class.matches_status?(
          error:  error,
          status: result_or_status,
          value:  value
        )
      end

      raise ArgumentError, 'argument must be a result or a status'
    end

    private

    def call_match(block:, result:)
      args = block.arity.zero? ? [] : [result]

      (match_context || self).instance_exec(*args, &block)
    end
  end
end
