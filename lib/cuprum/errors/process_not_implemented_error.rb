require 'cuprum/errors'

module Cuprum::Errors
  # Error class for calling a Command that was not given a definition block
  # or have a #process method defined.
  class ProcessNotImplementedError < StandardError
    # Error message for a ProcessNotImplementedError.
    DEFAULT_MESSAGE = 'no implementation defined for command'.freeze

    def initialize message = nil
      super(message || DEFAULT_MESSAGE)
    end
  end
end
