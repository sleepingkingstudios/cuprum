# frozen_string_literal: true

require 'rspec/sleeping_king_studios/deferred'

require 'cuprum/errors/invalid_parameters'
require 'cuprum/rspec/be_a_result'
require 'cuprum/rspec/deferred'

module Cuprum::RSpec::Deferred
  # Deferred examples for testing parameter validation.
  module ParameterValidationExamples
    include Cuprum::RSpec::Matchers
    include RSpec::SleepingKingStudios::Deferred::Provider

    deferred_examples 'should validate the parameter' \
    do |name, type = nil, message: nil, **options|
      it 'should return a failing result with InvalidParameters error' do
        expected_failure =
          message ||
          tools.assertions.error_message_for(type, as: name, **options)
        expected_error   = Cuprum::Errors::InvalidParameters.new(
          command_class: subject.class,
          failures:      [expected_failure]
        )

        expect(call_command)
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end

    private

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end
  end
end
