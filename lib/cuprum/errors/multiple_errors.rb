# frozen_string_literal: true

require 'cuprum/error'
require 'cuprum/errors'

module Cuprum::Errors
  # Error wrapping multiple errors from a collection command.
  class MultipleErrors < Cuprum::Error
    # Short string used to identify the type of error.
    TYPE = 'cuprum.errors.multiple_errors'

    # @param errors [Array<Cuprum::Error>] the wrapped errors.
    # @param backtrace [true, false] if true, captures a backtrace from
    #   Kernel.caller.
    # @param message [String] optional message describing the nature of the
    #   error.
    def initialize(errors:, backtrace: nil, message: nil)
      @errors = errors

      super
    end

    # @return [Array<Cuprum::Error>] the wrapped errors.
    attr_reader :errors

    private

    def as_json_data
      {
        'errors' => errors.map { |error| error&.as_json }
      }
    end
  end
end
