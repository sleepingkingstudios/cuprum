require 'cuprum'

module Cuprum
  # Data object that encapsulates the result of calling a Cuprum function or
  # operation.
  class Result
    # @return [Object] the value returned by calling the function.
    attr_accessor :value

    attr_writer :errors

    # @return [Array] the errors (if any) generated when the function was
    #   called.
    def errors
      @errors ||= []
    end # method errors

    # @return [Boolean] false if the function did not generate any errors,
    #   otherwise true.
    def failure?
      !errors.empty?
    end # method failure?

    # @return [Boolean] true if the function did not generate any errors,
    #   otherwise false.
    def success?
      errors.empty?
    end # method success?
  end # class
end # module
