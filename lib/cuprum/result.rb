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
    # In order to match the result, the object must respond to the #to_h method,
    # and the value of object.to_h must be equal to the value of
    # result.properties.
    #
    # @param other [#to_h] the result or object to compare.
    #
    # @return [Boolean] true if all values match the result, otherwise false.
    def ==(other)
      other = other.to_cuprum_result if other.respond_to?(:to_cuprum_result)

      return properties == other.to_h if other.respond_to?(:to_h)

      deprecated_compare(other)
    end

    # @return [Boolean] true if the result status is :failure, otherwise false.
    def failure?
      @status == :failure
    end

    # @return [Hash{Symbol => Object}] a Hash representation of the result.
    def properties
      {
        error:  error,
        status: status,
        value:  value
      }
    end
    alias_method :to_h, :properties

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

    def deprecated_compare(other)
      unless %i[value status error].all? { |sym| other.respond_to?(sym) }
        return false
      end

      tools.core_tools.deprecate 'Cuprum::Result#==',
        message: 'The compared object must respond to #to_h.'

      other.value == value &&
        other.status == status &&
        other.error  == error
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
