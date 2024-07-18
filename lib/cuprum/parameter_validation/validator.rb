# frozen_string_literal: true

require 'sleeping_king_studios/tools/assertions'

require 'cuprum/errors/invalid_parameters'
require 'cuprum/parameter_validation'

module Cuprum::ParameterValidation
  # Utility class for validating mapped parameters.
  class Validator
    # Exception raised when performing an unknown validation type.
    class UnknownValidationError < StandardError; end

    def initialize
      @failures = []
    end

    # Validates the given parameters.
    #
    # @param command [Object] the command whose parameters are validated.
    # @param parameters [Hash{Symbol=>Object}] the parameters to validate.
    # @param rules [Array<ValidationRule>] the rules used to validate the
    #   parameters.
    #
    # @return [Cuprum::Result] a result with the validation errors, if any.
    def call(command:, parameters:, rules:) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      validator.clear

      rules.each do |rule|
        value = parameters[rule.name]

        if rule.type == ValidationRule::BLOCK_VALIDATION_TYPE
          evaluate_block_validation(rule:, value:)
        elsif command.respond_to?(rule.method_name)
          evaluate_command_validation(command:, rule:, value:)
        elsif validator.respond_to?(rule.method_name)
          evaluate_validation(rule:, value:)
        else
          raise UnknownValidationError, error_message_for(command:, rule:)
        end
      end

      handle_failures_for(command)
    end

    private

    def error_message_for(command:, rule:)
      unless rule.type == ValidationRule::NAMED_VALIDATION_TYPE
        return "unknown validation type #{rule.type.inspect}"
      end

      "undefined method '#{rule.method_name}' for an instance of " \
        "#{command.class.name}"
    end

    def evaluate_block_validation(rule:, value:)
      return if rule.block.call(value)

      message = rule.options.fetch(
        :message,
        "#{rule.options.fetch(:as, rule.name)} is invalid"
      )
      validator << message
    end

    def evaluate_command_validation(command:, rule:, value:)
      message = command.send(
        rule.method_name,
        value,
        as: rule.name,
        **rule.options
      )

      validator << message if message
    end

    def evaluate_validation(rule:, value:)
      validator.send(
        rule.method_name,
        value,
        as: rule.name,
        **rule.options
      )
    end

    def handle_failures_for(command)
      return Cuprum::Result.new if validator.empty?

      error = Cuprum::Errors::InvalidParameters.new(
        command_class: command.class,
        failures:      validator.each.to_a
      )
      Cuprum::Result.new(error:)
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end

    def validator
      @validator ||= tools.assertions.aggregator_class.new
    end
  end
end
