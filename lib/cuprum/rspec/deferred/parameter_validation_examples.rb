# frozen_string_literal: true

require 'rspec/sleeping_king_studios/deferred'

require 'cuprum/errors/invalid_parameters'
require 'cuprum/rspec/be_a_result'
require 'cuprum/rspec/deferred'

module Cuprum::RSpec::Deferred
  # Deferred examples for testing parameter validation.
  #
  # @example With A Validation Type
  #   RSpec.describe LaunchRocket do
  #     include Cuprum::RSpec::Deferred::ParameterValidationExamples
  #
  #     describe '#call' do
  #       let(:launch_site) { 'KSC' }
  #
  #       def call_command
  #         subject.call(launch_site:)
  #       end
  #
  #       describe 'with invalid parameters' do
  #         let(:launch_site) { nil }
  #
  #         include_deferred 'should validate the parameter',
  #           :launch_site,
  #           'sleeping_king_studios.tools.assertions.presence',
  #           as: 'launch site'
  #       end
  #     end
  #   end
  #
  # @example With A Message
  #   RSpec.describe LaunchRocket do
  #     include Cuprum::RSpec::Deferred::ParameterValidationExamples
  #
  #     describe '#call' do
  #       let(:launch_site) { 'KSC' }
  #
  #       def call_command
  #         subject.call(launch_site:)
  #       end
  #
  #       describe 'with invalid parameters' do
  #         let(:launch_site) { nil }
  #
  #         include_deferred 'should validate the parameter',
  #           :launch_site,
  #           message: "launch site can't be blank"
  #       end
  #     end
  #   end
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
