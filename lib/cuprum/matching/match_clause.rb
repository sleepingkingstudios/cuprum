# frozen_string_literal: true

require 'cuprum/matching'

module Cuprum::Matching
  # @private
  #
  # Value object that represents a potential result match for a Matcher.
  #
  # Should not be instantiated directly; instead, instantiate a Cuprum::Matcher
  # or include Cuprum::Matching in a custom class.
  MatchClause = Struct.new(:block, :error, :status, :value) do
    include Comparable

    # @param other [Cuprum::Matching::MatchClause] The other result to compare.
    #
    # @return [Integer] the comparison result.
    def <=>(other)
      return nil unless other.is_a?(Cuprum::Matching::MatchClause)

      cmp = compare(value, other.value)

      return cmp unless cmp.zero?

      compare(error, other.error)
    end

    # Checks if the match clause matches the specified error and value.
    #
    # @return [Boolean] true if the error and value match, otherwise false.
    def matches_details?(error:, value:)
      return false unless matches_detail?(error, self.error)
      return false unless matches_detail?(value, self.value)

      true
    end

    # Checks if the match clause matches the given result.
    #
    # @return [Boolean] true if the result matches, otherwise false.
    def matches_result?(result:)
      return false unless error.nil? || result.error.is_a?(error)
      return false unless value.nil? || result.value.is_a?(value)

      true
    end

    private

    def compare(left, right)
      return  0 if left.nil? && right.nil?
      return  1 if left.nil?
      return -1 if right.nil?

      left <=> right || 0
    end

    def matches_detail?(actual, expected)
      return true  if actual.nil? && expected.nil?
      return false if actual.nil? || expected.nil?

      actual <= expected
    end
  end
end
