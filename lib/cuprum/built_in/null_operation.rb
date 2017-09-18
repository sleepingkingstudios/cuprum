require 'cuprum/built_in/null_function'
require 'cuprum/operation'

module Cuprum::BuiltIn
  # A predefined operation that does nothing when called.
  #
  # @example
  #   operation = NullOperation.new.call
  #   operation.value
  #   #=> nil
  #   operation.success?
  #   #=> true
  class NullOperation < Cuprum::BuiltIn::NullFunction
    include Cuprum::Operation::Mixin
  end # class
end # module
