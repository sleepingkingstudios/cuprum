# frozen_string_literal: true

require 'cuprum/rspec'

module Cuprum::RSpec
  module Matchers # rubocop:disable Style/Documentation
    def be_callable
      respond_to(:process, true)
    end
  end
end
