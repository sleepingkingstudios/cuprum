# frozen_string_literal: true

require 'cuprum/error'
require 'cuprum/errors'

module Cuprum::Errors
  # Error class to be used when trying to access the result of an uncalled
  # Operation.
  class OperationNotCalled < Cuprum::Error
    # Format for generating error message.
    MESSAGE_FORMAT = '%s was not called and does not have a result'

    # @param operation [Cuprum::Operation] The uncalled operation.
    def initialize(operation:)
      @operation = operation

      class_name = operation&.class&.name || 'operation'
      message    = MESSAGE_FORMAT % class_name

      super(message: message)
    end

    # @return [Cuprum::Operation] The uncalled operation.
    attr_reader :operation
  end
end
