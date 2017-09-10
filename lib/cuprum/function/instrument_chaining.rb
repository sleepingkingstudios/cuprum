require 'cuprum/function'

class Cuprum::Function
  # Module to add instrumentation to function chaining, allowing test or spec
  # files to reflect on chained functions or operations.
  #
  # @example Instrument chaining for one function.
  #   function.extend(Cuprum::Function::InstrumentChaining)
  #
  # @example Instrument chaining for all functions.
  #   Cuprum::Function.prepend(Cuprum::Function::InstrumentChaining)
  module InstrumentChaining
    private

    def build_chain_link function_or_proc, *rest
      hsh = super

      hsh[:fn] = function_or_proc if function_or_proc.is_a?(Cuprum::Function)

      hsh
    end # method build_chain_link
  end # module
end # class
