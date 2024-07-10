# frozen_string_literal: true

require 'cuprum/error'
require 'cuprum/errors'

module Cuprum::Errors
  # Error returned when trying to access the result of an uncalled Operation.
  class OperationNotCalled < Cuprum::Error
    MESSAGE_FORMAT = '%s was not called and does not have a result'
    private_constant :MESSAGE_FORMAT

    # Short string used to identify the type of error.
    TYPE = 'cuprum.errors.operation_not_called'

    # @param operation [Cuprum::Operation] The uncalled operation.
    def initialize(operation:)
      @operation = operation

      class_name = operation&.class&.name || 'operation'
      message    = MESSAGE_FORMAT % class_name

      super(message:, operation:)
    end

    # @return [Cuprum::Operation] The uncalled operation.
    attr_reader :operation

    private

    def as_json_data
      operation ? { 'class_name' => operation.class.name } : {}
    end
  end
end
