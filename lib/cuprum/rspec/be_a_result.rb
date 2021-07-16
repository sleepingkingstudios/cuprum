# frozen_string_literal: true

require 'cuprum/rspec/be_a_result_matcher'

module Cuprum::RSpec
  module Matchers # rubocop:disable Style/Documentation
    # Asserts that the object is a Cuprum::Result with status: :failure.
    #
    # @return [Cuprum::RSpec::BeAResultMatcher] the generated matcher.
    def be_a_failing_result
      be_a_result.with_status(:failure)
    end

    # Asserts that the object is a Cuprum::Result with status: :success.
    #
    # @return [Cuprum::RSpec::BeAResultMatcher] the generated matcher.
    def be_a_passing_result
      be_a_result.with_status(:success).and_error(nil)
    end

    # Asserts that the object is a Cuprum::Result.
    #
    # @return [Cuprum::RSpec::BeAResultMatcher] the generated matcher.
    def be_a_result
      Cuprum::RSpec::BeAResultMatcher.new
    end
  end
end
