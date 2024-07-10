# frozen_string_literal: true

require 'cuprum/error'
require 'cuprum/errors'

module Cuprum::Errors
  # Error wrapping multiple errors from a collection command.
  class MultipleErrors < Cuprum::Error
    # Short string used to identify the type of error.
    TYPE = 'cuprum.errors.multiple_errors'

    # @param errors [Array<Cuprum::Error>] The wrapped errors.
    # @param message [String] Optional message describing the nature of the
    #   error.
    def initialize(errors:, message: nil)
      @errors = errors

      super(
        errors:,
        message: message || default_message
      )
    end

    # @return [Array<Cuprum::Error>] the wrapped errors.
    attr_reader :errors

    private

    def as_json_data
      {
        'errors' => errors.map { |error| error&.as_json }
      }
    end

    def default_message
      'the command encountered one or more errors'
    end
  end
end
