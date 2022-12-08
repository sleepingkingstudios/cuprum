# frozen_string_literal: true

require 'cuprum/built_in'
require 'cuprum/command'

module Cuprum::BuiltIn
  # A predefined command that does nothing when called.
  #
  # @example
  #   result = NullCommand.new.call
  #   result.value
  #   #=> nil
  #   result.success?
  #   #=> true
  class NullCommand < Cuprum::Command
    def initialize
      super(&nil)
    end

    private

    def process(*_args, **_kwargs); end
  end
end
