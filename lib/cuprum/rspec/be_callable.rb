# frozen_string_literal: true

require 'cuprum/rspec'

module Cuprum::RSpec
  module Matchers # rubocop:disable Style/Documentation
    # Asserts that the command defines a :process method.
    #
    # @return [RSpec::Matchers::BuiltIn::RespondTo] the generated matcher.
    def be_callable
      respond_to(:process, true)
    end
  end
end
