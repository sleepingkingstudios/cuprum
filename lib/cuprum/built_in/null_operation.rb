# frozen_string_literal: true

require 'cuprum/built_in/null_command'
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
  class NullOperation < Cuprum::BuiltIn::NullCommand
    include Cuprum::Operation::Mixin
  end
end
