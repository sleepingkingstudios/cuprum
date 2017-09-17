require 'cuprum/built_in'
require 'cuprum/operation'

module Cuprum::BuiltIn
  # A predefined operation that does nothing when called.
  class NullOperation < Cuprum::Operation
    private

    def process; end
  end # class
end # module
