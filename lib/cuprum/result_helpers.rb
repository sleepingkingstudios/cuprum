require 'cuprum'

module Cuprum
  # Helper methods that delegate result methods to the currently processed
  # result.
  module ResultHelpers
    private

    # @!visibility public
    #
    # Provides a reference to the current result's errors object. Messages or
    # error objects added to this will be included in the #errors method of the
    # returned result object.
    #
    # @return [Array, Object] The errors object.
    #
    # @see Cuprum::Result#errors.
    #
    # @note This is a private method, and only available when executing the
    #   function implementation as defined in the constructor block or the
    #   #process method.
    def errors
      @result&.errors
    end # method errors

    # @!visibility public
    #
    # Marks the current result as failed. Calling #failure? on the returned
    # result object will evaluate to true, whether or not the result has any
    # errors.
    #
    # @see Cuprum::Result#failure!.
    #
    # @note This is a private method, and only available when executing the
    #   function implementation as defined in the constructor block or the
    #   #process method.
    def failure!
      @result&.failure!
    end # method failure!

    # @!visibility public
    #
    # Marks the current result as halted.
    #
    # @see Cuprum::Result#halt!.
    #
    # @note This is a private method, and only available when executing the
    #   function implementation as defined in the constructor block or the
    #   #process method.
    def halt!
      @result&.halt!
    end # method halt!
  end # module
end # module
