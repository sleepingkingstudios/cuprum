# frozen_string_literal: true

require 'cuprum/error'
require 'cuprum/errors'

module Cuprum::Errors
  # Error returned when a command encounters an unhandled exception.
  class UncaughtException < Cuprum::Error
    # Short string used to identify the type of error.
    TYPE = 'cuprum.errors.uncaught_exception'

    # @param exception [StandardError] The exception that was raised.
    # @param message [String] A message to display. Will be annotated with
    #   details on the exception and the exception's cause (if any).
    def initialize(exception:, message: 'uncaught exception')
      @exception = exception
      @cause     = exception.cause

      super(message: generate_message(message))
    end

    # @return [StandardError] the exception that was raised.
    attr_reader :exception

    private

    attr_reader :cause

    def as_json_data # rubocop:disable Metrics/MethodLength
      data = {
        'exception_backtrace' => exception.backtrace,
        'exception_class'     => exception.class,
        'exception_message'   => exception.message
      }

      return data unless cause

      data.update(
        {
          'cause_backtrace' => cause.backtrace,
          'cause_class'     => cause.class,
          'cause_message'   => cause.message
        }
      )
    end

    def generate_message(message)
      message = "#{message.rstrip} #{exception.class}: #{exception.message}"

      return message unless cause

      message + " caused by #{cause.class}: #{cause.message}"
    end
  end
end
