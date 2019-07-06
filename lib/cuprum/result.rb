# frozen_string_literal: true

require 'cuprum'

module Cuprum
  # Data object that encapsulates the result of calling a Cuprum command.
  class Result
    # @param value [Object] The value returned by calling the command.
    # @param error [Object] The error (if any) generated when the command was
    #   called. Can be a Cuprum::Error, a model errors object, etc.
    def initialize(value: nil, error: nil)
      @value  = value
      @error  = error
      @status = nil
    end

    # @return [Object] the value returned by calling the command.
    attr_accessor :value

    # @return [Object] the error (if any) generated when the command was
    #   called.
    attr_accessor :error

    # rubocop:disable Metrics/CyclomaticComplexity

    # Compares the other object to the result.
    #
    # @param other [#value, #success?] An object responding to, at minimum,
    #   #value and #success?. If present, the #failure? and #errors values
    #   will also be compared.
    #
    # @return [Boolean] True if all present values match the result, otherwise
    #   false.
    def ==(other)
      return false unless other.respond_to?(:value) && other.value == value

      unless other.respond_to?(:success?) && other.success? == success?
        return false
      end

      return false if other.respond_to?(:error) && other.error != error

      true
    end
    # rubocop:enable Metrics/CyclomaticComplexity

    # @return [Boolean] false if the command did not generate any errors,
    #   otherwise true.
    def failure?
      @status == :failure || (@status.nil? && !error.nil?)
    end

    # @return [Boolean] true if the command did not generate any errors,
    #   otherwise false.
    def success?
      @status == :success || (@status.nil? && error.nil?)
    end

    # @return [Cuprum::Result] The result.
    def to_cuprum_result
      self
    end

    protected

    attr_reader :status
  end
end
