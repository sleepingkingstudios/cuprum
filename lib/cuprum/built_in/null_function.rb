require 'cuprum/built_in'
require 'cuprum/function'

module Cuprum::BuiltIn
  # A predefined function that does nothing when called.
  class NullFunction < Cuprum::Function
    private

    def process; end
  end # class
end # module
