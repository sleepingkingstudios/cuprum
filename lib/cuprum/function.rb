require 'cuprum/basic_command'
require 'cuprum/not_implemented_error'
require 'cuprum/result'

module Cuprum
  # Functional object that encapsulates a business logic operation with a
  # consistent interface and tracking of result value and status.
  #
  # A Function can be defined either by passing a block to the constructor, or
  # by defining a subclass of Function and implementing the #process method.
  #
  # @example A Function with a block
  #   double_function = Cuprum::Function.new { |int| 2 * int }
  #   result          = double_function.call(5)
  #
  #   result.value #=> 10
  #
  # @example A Function subclass
  #   class MultiplyFunction < Cuprum::Function
  #     def initialize multiplier
  #       @multiplier = multiplier
  #     end # constructor
  #
  #     private
  #
  #     def process int
  #       int * @multiplier
  #     end # method process
  #   end # class
  #
  #   triple_function = MultiplyFunction.new(3)
  #   result          = triple_function.call(5)
  #
  #   result.value #=> 15
  #
  # @example A Function with errors
  #   class DivideFunction < Cuprum::Function
  #     def initialize divisor
  #       @divisor = divisor
  #     end # constructor
  #
  #     private
  #
  #     def process int
  #       if @divisor.zero?
  #         errors << 'errors.messages.divide_by_zero'
  #
  #         return
  #       end # if
  #
  #       int / @divisor
  #     end # method process
  #   end # class
  #
  #   halve_function = DivideFunction.new(2)
  #   result         = halve_function.call(10)
  #
  #   result.errors #=> []
  #   result.value  #=> 5
  #
  #   function_with_errors = DivideFunction.new(0)
  #   result               = function_with_errors.call(10)
  #
  #   result.errors #=> ['errors.messages.divide_by_zero']
  #   result.value  #=> nil
  #
  # @example Function Chaining
  #   class AddFunction < Cuprum::Function
  #     def initialize addend
  #       @addend = addend
  #     end # constructor
  #
  #     private
  #
  #     def process int
  #       int + @addend
  #     end # method process
  #   end # class
  #
  #   double_and_add_one = MultiplyFunction.new(2).chain(AddFunction.new(1))
  #   result             = double_and_add_one(5)
  #
  #   result.value #=> 5
  #
  # @example Conditional Chaining With #then And #else
  #   class EvenFunction < Cuprum::Function
  #     private
  #
  #     def process int
  #       errors << 'errors.messages.not_even' unless int.even?
  #
  #       int
  #     end # method process
  #   end # class
  #
  #   # The next step in a Collatz sequence is determined as follows:
  #   # - If the number is even, divide it by 2.
  #   # - If the number is odd, multiply it by 3 and add 1.
  #   collatz_function =
  #     EvenFunction.new.
  #       then(DivideFunction.new(2)).
  #       else(MultiplyFunction.new(3).chain(AddFunction.new(1)))
  #
  #   result = collatz_function.new(5)
  #   result.value #=> 16
  #
  #   result = collatz_function.new(16)
  #   result.value #=> 8
  class Function < Cuprum::BasicCommand
    # (see Cuprum::BasicCommand#call)
    def call *args, &block
      call_chained_functions { super }
    end # method call

    # Registers a function or block to run after the current function, or after
    # the last chained function if the current function already has one or more
    # chained function(s). This creates and modifies a copy of the current
    # function.
    #
    # @param on [Symbol] Sets a condition on when the chained function can run,
    #   based on the status of the previous function. Valid values are :success,
    #   :failure, and :always. A value of :success will constrain the function
    #   to run only if the previous function succeeded. A value of :failure will
    #   constrain the function to run only if the previous function failed. A
    #   value of :always will ensure the function is always run, even if the
    #   function chain has been halted. If no value is given, the function will
    #   run whether the previous function was a success or a failure, but not if
    #   the function chain has been halted.
    #
    # @overload chain(function, on: nil)
    #   The function will be passed the #value of the previous function result
    #   as its parameter, and the result of the chained function will be
    #   returned (or passed to the next chained function, if any).
    #
    #   @param function [Cuprum::Function] The function to call after the
    #     current or last chained function.
    #
    # @overload chain(on: :nil, &block)
    #   The block will be passed the #result of the previous function as its
    #   parameter. If your use case depends on the status of the previous
    #   function or on any errors generated, use the block form of #chain.
    #
    #   If the block returns a Cuprum::Result (or an object responding to #value
    #   and #success?), the block result will be returned (or passed to the next
    #   chained function, if any). If the block returns any other value
    #   (including nil), the #result of the previous function will be returned
    #   or passed to the next function.
    #
    #   @yieldparam result [Cuprum::Result] The #result of the previous
    #     function.
    #
    # @return [Cuprum::Function] The chained function.
    def chain function = nil, on: nil, &block
      clone.tap do |fn|
        fn.chained_functions << build_chain_link(block || function, :on => on)
      end # tap
    end # method chain

    # Shorthand for function.chain(:on => :failure). Registers a function or
    # block to run after the current function. The chained function will only
    # run if the previous function was unsuccessfully run.
    #
    # @overload else(function)
    #
    #   @param function [Cuprum::Function] The function to call after the
    #     current or last chained function.
    #
    # @overload else(&block)
    #
    #   @yieldparam result [Cuprum::Result] The #result of the previous
    #     function.
    #
    # @return [Cuprum::Function] The chained function.
    #
    # @see #chain
    def else function = nil, &block
      chain(function, :on => :failure, &block)
    end # method else

    # Shorthand for function.chain(:on => :success). Registers a function or
    # block to run after the current function. The chained function will only
    # run if the previous function was successfully run.
    #
    # @overload then(function)
    #
    #   @param function [Cuprum::Function] The function to call after the
    #     current or last chained function.
    #
    # @overload then(&block)
    #
    #   @yieldparam result [Cuprum::Result] The #result of the previous
    #     function.
    #
    # @return [Cuprum::Function] The chained function.
    #
    # @see #chain
    def then function = nil, &block
      chain(function, :on => :success, &block)
    end # method then

    protected

    def chained_functions
      @chained_functions ||= []
    end # method chained_functions

    private

    def build_chain_link function_or_proc, on: nil
      {
        :proc => convert_function_or_proc_to_proc(function_or_proc),
        :on   => on
      } # end hash
    end # method build_chain_link

    def call_chained_functions
      chained_functions.reduce(yield) do |result, hsh|
        next result if skip_chained_function?(result, :on => hsh[:on])

        value = hsh.fetch(:proc).call(result)

        convert_value_to_result(value) || result
      end # reduce
    end # method call_chained_functions

    def convert_function_or_proc_to_proc function_or_proc
      return function_or_proc if function_or_proc.is_a?(Proc)

      ->(result) { function_or_proc.call(result) }
    end # method convert_function_or_proc_to_proc

    def skip_chained_function? last_result, on:
      return false if on == :always

      return true if last_result.respond_to?(:halted?) && last_result.halted?

      case on
      when :success
        !last_result.success?
      when :failure
        !last_result.failure?
      end # case
    end # method skip_chained_function?
  end # class
end # module
