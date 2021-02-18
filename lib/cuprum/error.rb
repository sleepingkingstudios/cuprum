# frozen_string_literal: true

require 'cuprum'

module Cuprum
  # Wrapper class for encapsulating an error state for a failed Cuprum result.
  # Additional details can be passed by setting the #message or by using a
  # subclass of Cuprum::Error.
  class Error
    # @param message [String] Optional message describing the nature of the
    #   error.
    # @param properties [Hash] Additional properties used to compare errors.
    def initialize(message: nil, **properties)
      @message               = message
      @comparable_properties = properties.merge(message: message)
    end

    # @return [String] Optional message describing the nature of the error.
    attr_reader :message

    # @param other [Cuprum::Error] The other object to compare.
    #
    # @return [Boolean] true if the other object has the same class and
    #   properties; otherwise false.
    def ==(other)
      other.instance_of?(self.class) &&
        other.comparable_properties == comparable_properties
    end

    protected

    attr_reader :comparable_properties
  end
end
