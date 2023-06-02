# frozen_string_literal: true

require 'cuprum/rspec/be_a_result_matcher'

module Cuprum::RSpec
  module Matchers # rubocop:disable Style/Documentation
    # Asserts that the object is a result with status: :failure.
    #
    # @param expected_class [Class] the expected class of result. Defaults to
    #   Cuprum::Result.
    #
    # @return [Cuprum::RSpec::BeAResultMatcher] the generated matcher.
    def be_a_failing_result(expected_class = nil)
      be_a_result(expected_class).with_status(:failure)
    end

    # Asserts that the object is a Cuprum::Result with status: :success.
    #
    # @param expected_class [Class] the expected class of result. Defaults to
    #   Cuprum::Result.
    #
    # @return [Cuprum::RSpec::BeAResultMatcher] the generated matcher.
    def be_a_passing_result(expected_class = nil)
      be_a_result(expected_class).with_status(:success).and_error(nil)
    end

    # Asserts that the object is a Cuprum::Result.
    #
    # @return [Cuprum::RSpec::BeAResultMatcher] the generated matcher.
    def be_a_result(expected_class = nil)
      Cuprum::RSpec::BeAResultMatcher.new(expected_class)
    end
  end
end
