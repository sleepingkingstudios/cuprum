# frozen_string_literal: true

require 'cuprum'

module Cuprum
  # Wrapper class for encapsulating an error state for a failed Cuprum result.
  #
  # Additional details can be passed by setting the #message or by using a
  # subclass of Cuprum::Error.
  #
  # @example
  #   error = Cuprum::Error.new(message: 'Something went wrong')
  #   error.type
  #   #=> 'cuprum.error'
  #   error.message
  #   #=> 'Something went wrong'
  #
  # @example An Error With Custom Type
  #   error = Cuprum::Error.new(
  #     message: 'Something went wrong',
  #     type:    'custom.errors.generic',
  #   )
  #   error.type
  #   #=> 'custom.errors.generic'
  #
  # @example An Error Subclass
  #   class LightsError < Cuprum::Error
  #     TYPE = 'custom.errors.wrong_number_of_lights'
  #
  #     def initialize(count)
  #       super(message: "There are #{count} lights!")
  #
  #       @count = count
  #     end
  #
  #     private def as_json_data
  #       { 'count' => count }
  #     end
  #   end
  #
  #   error = LightsError.new(4)
  #   error.type
  #   #=> 'custom.errors.wrong_number_of_lights'
  #   error.message
  #   #=> 'There are 4 lights!'
  #   error.as_json
  #   #=> {
  #   #     'data'    => { 'count' => 4 },
  #   #     'message' => 'There are 4 lights!',
  #   #     'type'    => 'custom.errors.wrong_number_of_lights'
  #   #   }
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

    # Generates a serializable representation of the error object.
    #
    # By default, contains the #type and #message properties and an empty :data
    # Hash. This can be overriden in subclasses by overriding the private method
    # #as_json_data; this should always return a Hash with String keys and whose
    # values are basic objects or data structures of the same.
    #
    # @return [Hash<String, Object>] a serializable hash representation of the
    #   error.
    def as_json
      {
        'data'    => as_json_data,
        'message' => message,
        'type'    => type
      }
    end

    protected

    attr_reader :comparable_properties

    private

    def as_json_data
      {}
    end
  end
end
