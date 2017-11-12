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

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/MethodLength
    # rubocop:disable Metrics/PerceivedComplexity

    # Compares the other object to the result.
    #
    # @param other [#value, #success?] An object responding to, at minimum,
    #   #value and #success?. If present, the #failure?, #errors and #halted?
    #   values will also be compared.
    #
    # @return [Boolean] True if all present values match the result, otherwise
    #   false.
    def == other
      return false unless other.respond_to?(:value) && other.value == value

      unless other.respond_to?(:success?) && other.success? == success?
        return false
      end # unless

      if other.respond_to?(:failure?) && other.failure? != failure?
        return false
      end # if

      if other.respond_to?(:errors) && other.errors != errors
        return false
      end # if

      if other.respond_to?(:halted?) && other.halted? != halted?
        return false
      end # if

      true
    end # method ==
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/MethodLength
    # rubocop:enable Metrics/PerceivedComplexity

    # @return [Boolean] true if the result is empty, i.e. has no value or errors
    #   and does not have its status set or is halted.
    def empty?
      value.nil? && errors.empty? && @status.nil? && !halted?
    end # method empty?

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

    # @api private
    def update other_result
      return self if other_result.nil?

      self.value = other_result.value

      update_status(other_result)

      update_errors(other_result)

      halt! if other_result.halted?

      self
    end # method update

    protected

    attr_reader :status

    private

    def update_errors other_result
      return if other_result.errors.empty?

      @errors += other_result.errors
    end # method update_errors

    def update_status other_result
      return if status || !errors.empty?

      @status = other_result.status
    end # method update_status
  end # class
end # module
