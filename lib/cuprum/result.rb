# frozen_string_literal: true

require 'cuprum'

module Cuprum
  # Data object that encapsulates the result of calling a Cuprum command.
  class Result
    # Enumerates the default permitted values for a Result#status.
    STATUSES = %i[success failure].freeze

    # @param value [Object] the value returned by calling the command.
    # @param error [Object] the error (if any) generated when the command was
    #   called. Can be a Cuprum::Error, a model errors object, etc.
    # @param status [String, Symbol] the status of the result. Must be :success,
    #   :failure, or nil.
    def initialize(value: nil, error: nil, status: nil)
      @value  = value
      @error  = error
      @status = resolve_status(status)
    end

    # @return [Object] the value returned by calling the command.
    attr_reader :value

    # @return [Object] the error (if any) generated when the command was
    #   called.
    attr_reader :error

    # @return [Symbol] the status of the result, either :success or :failure.
    attr_reader :status

    # Compares the other object to the result.
    #
    # In order to match the result, the object must respond to the #value,
    # #status, and #error methods, and the values of each of those methods must
    # be equal to the equivalent value on the result.
    #
    # @param other [#error, #status, #value] the result or object to compare.
    #
    # @return [Boolean] true if all values match the result, otherwise false.
    def ==(other)
      return false unless other.respond_to?(:value)  && other.value  == value
      return false unless other.respond_to?(:status) && other.status == status
      return false unless other.respond_to?(:error)  && other.error  == error

      true
    end

    # @return [Boolean] true if the result status is :failure, otherwise false.
    def failure?
      @status == :failure
    end

    # @return [Boolean] true if the result status is :success, otherwise false.
    def success?
      @status == :success
    end

    # @return [Cuprum::Result] The result.
    def to_cuprum_result
      self
    end

    private

    def defined_statuses
      self.class::STATUSES
    end

    def normalize_status(status)
      return status unless status.is_a?(String) || status.is_a?(Symbol)

      tools.string_tools.underscore(status).intern
    end

    def resolve_status(status)
      return error.nil? ? :success : :failure if status.nil?

      normalized = normalize_status(status)

      return normalized if defined_statuses.include?(normalized)

      raise ArgumentError, "invalid status #{status.inspect}"
    end

    def tools
      SleepingKingStudios::Tools::Toolbelt.instance
    end
  end
end
