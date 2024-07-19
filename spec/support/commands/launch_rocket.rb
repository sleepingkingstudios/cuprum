# frozen_string_literal: true

require 'cuprum/command'
require 'cuprum/parameter_validation'

require 'support/models/rocket'

module Spec::Commands
  class LaunchRocket < Cuprum::Command
    include Cuprum::ParameterValidation

    validate :launch_site,
      :name,
      as: 'launch pad'
    validate :payload,
      message: 'payload is too heavy' \
      do |payload|
        payload[:mass] < 1_000
      end
    validate :rocket
    validate :rocket, Spec::Models::Rocket

    private

    def process(rocket, launch_site:, payload: {}) # rubocop:disable Lint/UnusedMethodArgument
      rocket.launched = true
    end

    def validate_rocket(rocket, **)
      return unless rocket.is_a?(Spec::Models::Rocket)

      return if rocket.launched == false

      'rocket has already launched'
    end
  end
end
