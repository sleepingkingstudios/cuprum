# frozen_string_literal: true

require 'cuprum/error'
require 'cuprum/errors'

module Cuprum::Errors
  # Error returned when a command's parameters fail validation.
  class InvalidParameters < Cuprum::Error
    # Short string used to identify the type of error.
    TYPE = 'cuprum.errors.invalid_parameters'

    # @param command_class [Class] the class of the failed command.
    # @param failures [Array<String>] the messages for the failed validations.
    def initialize(command_class:, failures:)
      @command_class   = command_class
      @failures        = failures
      class_name       = command_class.name
      failure_messages = failures.join(', ')

      super(
        class_name:,
        command_class:,
        failures:,
        failure_messages:
      )
    end

    # @return [Class] the class of the failed command.
    attr_reader :command_class

    # @return [Array<String>] the messages for the failed validations.
    attr_reader :failures

    private

    def as_json_data
      {
        'command_class' => command_class.name,
        'failures'      => failures.map(&:to_s)
      }
    end
  end
end
