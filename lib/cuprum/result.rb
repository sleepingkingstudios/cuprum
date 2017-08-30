require 'cuprum'

module Cuprum
  # Data object that encapsulates the result of calling a Cuprum function or
  # operation.
  class Result
    # @param value [Object] The value returned by calling the function.
    # @param errors [Array] The errors (if any) generated when the function was
    #   called.
    def initialize value = nil, errors: []
      @value  = value
      @errors = errors
      @status = nil
      @halted = false
    end # constructor

    # @return [Object] the value returned by calling the function.
    attr_accessor :value

    # @return [Array] the errors (if any) generated when the function was
    #   called.
    attr_accessor :errors

    # Marks the result as a failure, whether or not the function generated any
    # errors.
    #
    # @return [Cuprum::Result] The result.
    def failure!
      @status = :failure

      self
    end # method failure!

    # @return [Boolean] false if the function did not generate any errors,
    #   otherwise true.
    def failure?
      @status == :failure || (@status.nil? && !errors.empty?)
    end # method failure?

    # Marks the result as halted. Any subsequent chained functions will not be
    #   run.
    #
    # @return [Cuprum::Result] The result.
    def halt!
      @halted = true

      self
    end # method halt!

    # @return [Boolean] true if the function has been halted, and will not run
    #   any subsequent chained functions.
    def halted?
      @halted
    end # method halted?

    # Marks the result as a success, whether or not the function generated any
    # errors.
    #
    # @return [Cuprum::Result] The result.
    def success!
      @status = :success

      self
    end # method success!

    # @return [Boolean] true if the function did not generate any errors,
    #   otherwise false.
    def success?
      @status == :success || (@status.nil? && errors.empty?)
    end # method success?
  end # class
end # module
