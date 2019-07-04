# frozen_string_literal: true

require 'cuprum'

module Cuprum
  # Data object that encapsulates the result of calling a Cuprum command.
  class Result
    # @param value [Object] The value returned by calling the command.
    # @param errors [Array] The errors (if any) generated when the command was
    #   called.
    def initialize(value: nil, errors: nil)
      @value  = value
      @errors = errors
      @status = nil
    end

    # @return [Object] the value returned by calling the command.
    attr_accessor :value

    # @return [Array] the errors (if any) generated when the command was
    #   called.
    attr_accessor :errors

    # rubocop:disable Metrics/AbcSize
    # rubocop:disable Metrics/CyclomaticComplexity
    # rubocop:disable Metrics/PerceivedComplexity

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

      return false if other.respond_to?(:failure?) && other.failure? != failure?

      return false if other.respond_to?(:errors) && other.errors != errors

      true
    end
    # rubocop:enable Metrics/AbcSize
    # rubocop:enable Metrics/CyclomaticComplexity
    # rubocop:enable Metrics/PerceivedComplexity

    # @return [Boolean] false if the command did not generate any errors,
    #   otherwise true.
    def failure?
      @status == :failure || (@status.nil? && !errors.nil?)
    end

    # @return [Boolean] true if the command did not generate any errors,
    #   otherwise false.
    def success?
      @status == :success || (@status.nil? && errors.nil?)
    end

    # @return [Cuprum::Result] The result.
    def to_cuprum_result
      self
    end

    protected

    attr_reader :status
  end
end
