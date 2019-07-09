# frozen_string_literal: true

require 'cuprum/error'
require 'cuprum/errors'

module Cuprum::Errors
  # Error class to be used when a Command is called without defining a #process
  # method.
  class CommandNotImplemented < Cuprum::Error
    # Format for generating error message.
    MESSAGE_FORMAT = 'no implementation defined for %s'

    # @param command [Cuprum::Command] The command called without a definition.
    def initialize(command:)
      @command = command

      class_name = command&.class&.name || 'command'
      message    = MESSAGE_FORMAT % class_name

      super(message: message)
    end

    # @return [Cuprum::Command] The command called without a definition.
    attr_reader :command
  end
end
