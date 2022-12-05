# frozen_string_literal: true

require 'cuprum/built_in'
require 'cuprum/command'

module Cuprum::BuiltIn
  # A predefined command that returns the value or result it was called with.
  #
  # @example With a value.
  #   result = IdentityCommand.new.call('custom value')
  #   result.value
  #   #=> 'custom value'
  #   result.success?
  #   #=> true
  #
  # @example With a result.
  #   error  = 'errors.messages.unknown'
  #   value  = Cuprum::Result.new(value: 'result value', error: error)
  #   result = IdentityCommand.new.call(value)
  #   result.value
  #   #=> 'result value'
  #   result.success?
  #   #=> false
  #   result.error
  #   #=> 'errors.messages.unknown'
  class IdentityCommand < Cuprum::Command
    def initialize
      super(&nil)
    end

    private

    def process(value = nil)
      value
    end
  end
end
