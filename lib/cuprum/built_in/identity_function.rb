require 'cuprum/built_in'
require 'cuprum/command'

module Cuprum::BuiltIn
  # A predefined function that returns the value or result it was called with.
  #
  # @example With a value.
  #   result = IdentityFunction.new.call('custom value')
  #   result.value
  #   #=> 'custom value'
  #   result.success?
  #   #=> true
  #
  # @example With a result.
  #   errors = ['errors.messages.unknown']
  #   value  = Cuprum::Result.new('result value', :errors => errors)
  #   result = IdentityFunction.new.call(value)
  #   result.value
  #   #=> 'result value'
  #   result.success?
  #   #=> false
  #   result.errors
  #   #=> ['errors.messages.unknown']
  class IdentityFunction < Cuprum::Command
    private

    def process value = nil
      value
    end # method process
  end # class
end # module
