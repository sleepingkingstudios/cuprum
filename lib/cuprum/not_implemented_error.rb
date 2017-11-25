require 'cuprum'

module Cuprum
  # Error class for calling a Command that was not given a definition block
  # or have a #process method defined.
  class NotImplementedError < StandardError
    # Error message for a NotImplementedError.
    DEFAULT_MESSAGE = 'no implementation defined for command'.freeze

    def initialize message = nil
      super(message || DEFAULT_MESSAGE)
    end # constructor
  end # class
end # module
