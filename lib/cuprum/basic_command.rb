require 'cuprum/processing'

module Cuprum
  # Functional object that encapsulates a business logic operation with a
  # standardized interface and returns a result object.
  class BasicCommand
    include Cuprum::Processing

    # Returns a new instance of Cuprum::BasicCommand.
    #
    # @yield [*arguments, **keywords, &block] If a block is given, the
    #   #call method will wrap the block and set the result #value to the return
    #   value of the block. This overrides the implementation in #process, if
    #   any.
    def initialize &implementation
      define_singleton_method :process, &implementation if implementation
    end # method initialize
  end # class
end # module
