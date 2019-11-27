# frozen_string_literal: true

require 'cuprum/rspec/be_a_result_matcher'

module RSpec
  module Matchers # rubocop:disable Style/Documentation
    def be_a_failing_result
      be_a_result.with_status(:failure)
    end

    def be_a_passing_result
      be_a_result.with_status(:success).and_error(nil)
    end

    def be_a_result
      Cuprum::RSpec::BeAResultMatcher.new
    end
  end
end
