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
      @errors = errors.nil? ? build_errors : errors
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

    # @return [Boolean] true if the result is empty, i.e. has no value or errors
    #   and does not have its status set.
    def empty?
      value.nil? && errors.empty? && @status.nil?
    end

    # Marks the result as a failure, whether or not the command generated any
    # errors.
    #
    # @return [Cuprum::Result] The result.
    def failure!
      @status = :failure

      self
    end

    # @return [Boolean] false if the command did not generate any errors,
    #   otherwise true.
    def failure?
      @status == :failure || (@status.nil? && !errors.empty?)
    end

    # Marks the result as a success, whether or not the command generated any
    # errors.
    #
    # @return [Cuprum::Result] The result.
    def success!
      @status = :success

      self
    end

    # @return [Boolean] true if the command did not generate any errors,
    #   otherwise false.
    def success?
      @status == :success || (@status.nil? && errors.empty?)
    end

    # @return [Cuprum::Result] The result.
    def to_cuprum_result
      self
    end

    # @api private
    def update(other_result)
      return self if other_result.nil?

      self.value = other_result.value

      update_status(other_result)

      update_errors(other_result)

      self
    end

    protected

    attr_reader :status

    private

    # @!visibility public
    #
    # Generates an empty errors object. When the command is called, the result
    # will have its #errors property initialized to the value returned by
    # #build_errors. By default, this is an array. If you want to use a custom
    # errors object type, override this method in a subclass.
    #
    # @return [Array] An empty errors object.
    def build_errors
      []
    end

    def update_errors(other_result)
      return if other_result.errors.empty?

      @errors += other_result.errors
    end

    def update_status(other_result)
      return if status || !errors.empty?

      @status = other_result.status
    end
  end
end
