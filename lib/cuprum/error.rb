# frozen_string_literal: true

require 'cuprum'

module Cuprum
  # Wrapper class for encapsulating an error state for a failed Cuprum result.
  #
  # Additional details can be passed by setting the #message or by using a
  # subclass of Cuprum::Error.
  class Error
    # Short string used to identify the type of error.
    #
    # Primarily used for serialization. This value can be overriden by passing
    # in the :type parameter to the constructor.
    #
    # Subclasses of Cuprum::Error should define their own default TYPE constant.
    TYPE = 'cuprum.error'

    # @param message [String] Optional message describing the nature of the
    #   error.
    # @param properties [Hash] Additional properties used to compare errors.
    # @param type [String] Short string used to identify the type of error.
    def initialize(message: nil, type: nil, **properties)
      @message               = message
      @type                  = type || self.class::TYPE
      @comparable_properties = properties.merge(message: message, type: type)
    end

    # @return [String] optional message describing the nature of the error.
    attr_reader :message

    # @return [String] short string used to identify the type of error.
    attr_reader :type

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
