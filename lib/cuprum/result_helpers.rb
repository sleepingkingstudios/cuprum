require 'cuprum'

module Cuprum
  # Helper methods that delegate result methods to the currently processed
  # result.
  #
  # @example
  #   class LogCommand
  #     include Cuprum::Processing
  #     include Cuprum::ResultHelpers
  #
  #     private
  #
  #     def process log
  #       case log[:level]
  #       when 'fatal'
  #         halt!
  #
  #         'error'
  #       when 'error' && log[:message]
  #         errors << message
  #
  #         'error'
  #       when 'error'
  #         failure!
  #
  #         'error'
  #       else
  #         'ok'
  #       end # case
  #     end # method process
  #   end # class
  #
  #   result = LogCommand.new.call(:level => 'info')
  #   result.success? #=> true
  #
  #   string = 'something went wrong'
  #   result = LogCommand.new.call(:level => 'error', :message => string)
  #   result.success? #=> false
  #   result.errors   #=> ['something went wrong']
  #
  #   result = LogCommand.new.call(:level => 'error')
  #   result.success? #=> false
  #   result.errors   #=> []
  #
  #   result = LogCommand.new.call(:level => 'fatal')
  #   result.halted? #=> true
  #
  # @see Cuprum::Command
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
    #   command implementation as defined in the constructor block or the
    #   #process method.
    def errors
      result&.errors
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
    #   command implementation as defined in the constructor block or the
    #   #process method.
    def failure!
      result&.failure!
    end # method failure!

    # @!visibility public
    #
    # Marks the current result as halted.
    #
    # @see Cuprum::Result#halt!.
    #
    # @note This is a private method, and only available when executing the
    #   command implementation as defined in the constructor block or the
    #   #process method.
    def halt!
      result&.halt!
    end # method halt!

    # @!visibility public
    #
    # Marks the current result as passing. Calling #success? on the returned
    # result object will evaluate to true, whether or not the result has any
    # errors.
    #
    # @see Cuprum::Result#success!.
    #
    # @note This is a private method, and only available when executing the
    #   command implementation as defined in the constructor block or the
    #   #process method.
    def success!
      result&.success!
    end # method success!
  end # module
end # module
