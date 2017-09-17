require 'cuprum/operation'
require 'cuprum/operations'

module Cuprum::Operations
  # A predefined operation that does nothing when called.
  class NullOperation < Cuprum::Operation
    private

    def process; end
  end # class
end # module
