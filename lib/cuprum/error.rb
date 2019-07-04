# frozen_string_literal: true

require 'cuprum'

module Cuprum
  # Wrapper class for encapsulating an error state for a failed Cuprum result.
  # Additional details can be passed by setting the #message or by using a
  # subclass of Cuprum::Error.
  class Error
    # @param message [String] Optional message describing the nature of the
    #   error.
    def initialize(message: nil)
      @message = message
    end

    # @return [String] Optional message describing the nature of the error.
    attr_reader :message
  end
end
