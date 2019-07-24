# frozen_string_literal: true

require 'cuprum/rspec/be_a_result_matcher'

module RSpec
  module Matchers # rubocop:disable Style/Documentation
    def be_a_result
      Cuprum::RSpec::BeAResultMatcher.new
    end
  end
end
