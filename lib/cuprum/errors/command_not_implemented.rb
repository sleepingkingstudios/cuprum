# frozen_string_literal: true

require 'cuprum/error'
require 'cuprum/errors'

module Cuprum::Errors
  # Error returned when a Command is called without defining a #process method.
  class CommandNotImplemented < Cuprum::Error
    COMPARABLE_PROPERTIES = %i[command].freeze
    private_constant :COMPARABLE_PROPERTIES

    MESSAGE_FORMAT = 'no implementation defined for %s'
    private_constant :MESSAGE_FORMAT

    # Short string used to identify the type of error.
    TYPE = 'cuprum.errors.command_not_implemented'

    # @param command [Cuprum::Command] The command called without a definition.
    def initialize(command:)
      @command = command

      class_name = command&.class&.name || 'command'
      message    = MESSAGE_FORMAT % class_name

      super(command:, message:)
    end

    # @return [Cuprum::Command] The command called without a definition.
    attr_reader :command

    private

    def as_json_data
      command ? { 'class_name' => command.class.name } : {}
    end
  end
end
