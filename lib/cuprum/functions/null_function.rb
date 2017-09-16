require 'cuprum/function'
require 'cuprum/functions'

module Cuprum::Functions
  # A predefined function that does nothing when called.
  class NullFunction < Cuprum::Function
    private

    def process; end
  end # class
end # module
