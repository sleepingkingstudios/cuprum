require 'cuprum/built_in'
require 'cuprum/function'

module Cuprum::BuiltIn
  # A predefined function that does nothing when called.
  #
  # @example
  #   result = NullFunction.new.call
  #   result.value
  #   #=> nil
  #   result.success?
  #   #=> true
  class NullFunction < Cuprum::Function
    private

    def process *_args; end
  end # class
end # module
