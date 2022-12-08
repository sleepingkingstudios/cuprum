# frozen_string_literal: true

require 'cuprum/built_in/identity_command'
require 'cuprum/operation'

module Cuprum::BuiltIn
  # A predefined operation that returns the value or result it was called with.
  #
  # @example With a value.
  #   operation = IdentityOperation.new.call('custom value')
  #   operation.value
  #   #=> 'custom value'
  #   operation.success?
  #   #=> true
  #
  # @example With a result.
  #   error     = 'errors.messages.unknown'
  #   value     = Cuprum::Result.new(value: 'result value', error: error)
  #   operation = IdentityOperation.new.call(value)
  #   operation.value
  #   #=> 'result value'
  #   operation.success?
  #   #=> false
  #   operation.error
  #   #=> 'errors.messages.unknown'
  class IdentityOperation < Cuprum::BuiltIn::IdentityCommand
    include Cuprum::Operation::Mixin
  end
end
