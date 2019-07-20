# frozen_string_literal: true

require 'cuprum'

module Cuprum
  # Wrapper class for encapsulating an error state for a failed Cuprum result.
  # Additional details can be passed by setting the #message or by using a
  # subclass of Cuprum::Error.
  class Error
    COMPARABLE_PROPERTIES = %i[message].freeze
    private_constant :COMPARABLE_PROPERTIES

    # @param message [String] Optional message describing the nature of the
    #   error.
    def initialize(message: nil)
      @message = message
    end

    # @return [String] Optional message describing the nature of the error.
    attr_reader :message

    # @param other [Cuprum::Error] The other object to compare.
    #
    # @return [Boolean] true if the other object has the same class and message;
    #   otherwise false.
    def ==(other)
      other.instance_of?(self.class) &&
        comparable_properties.all? { |prop| send(prop) == other.send(prop) }
    end

    private

    def comparable_properties
      self.class.const_get(:COMPARABLE_PROPERTIES)
    end
  end
end
