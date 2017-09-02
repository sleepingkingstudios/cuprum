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
  class Function
    # Error class for calling a Function that was not given a definition block
    # or have a #process method defined.
    class NotImplementedError < StandardError
      # Error message for a NotImplementedError.
      DEFAULT_MESSAGE = 'no implementation defined for function'.freeze

      def initialize message = nil
        super(message || DEFAULT_MESSAGE)
      end # constructor
    end # class

    # Returns a new instance of Cuprum::Function.
    #
    # @yield [*arguments, **keywords, &block] If a block is given, the
    #   #call method will wrap the block and set the result #value to the return
    #   value of the block. This overrides the implementation in #process, if
    #   any.
    def initialize &implementation
      define_singleton_method :process, &implementation if implementation
    end # method initialize

    # @overload call(*arguments, **keywords, &block)
    #   Executes the logic encoded in the constructor block, or the #process
    #   method if no block was passed to the constructor, and returns a
    #   Cuprum::Result object with the return value of the block or #process,
    #   the success or failure status, and any errors generated.
    #
    #   @param arguments [Array] Arguments to be passed to the implementation.
    #
    #   @param keywords [Hash] Keywords to be passed to the implementation.
    #
    #   @return [Cuprum::Result] The result object for the function.
    #
    #   @yield If a block argument is given, it will be passed to the
    #     implementation.
    #
    #   @raise [NotImplementedError] Unless a block was passed to the
    #     constructor or the #process method was overriden by a Function
    #     subclass.
    def call *args, &block
      call_chained_functions do
        Cuprum::Result.new(:errors => build_errors).tap do |result|
          @result = result

          merge_results(result, process(*args, &block))

          @result = nil
        end # tap
      end # call_chained_functions
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
      proc = convert_function_or_proc_to_proc(block || function)

      chain_function(proc, :on => on)
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
      proc = convert_function_or_proc_to_proc(block || function)

      chain_function(proc, :on => :failure)
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
      proc = convert_function_or_proc_to_proc(block || function)

      chain_function(proc, :on => :success)
    end # method then

    protected

    def chain_function proc, on: nil
      hsh = { :proc => proc }
      hsh[:on] = on if on

      clone.tap do |fn|
        fn.chained_functions << hsh
      end # tap
    end # method chain_function

    def chained_functions
      @chained_functions ||= []
    end # method chained_functions

    private

    def build_errors
      []
    end # method build_errors

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

    def convert_value_to_result value
      return nil unless value_is_result?(value)

      if value.respond_to?(:result) && value_is_result?(value.result)
        return value.result
      end # if

      value
    end # method convert_value_to_result

    def errors
      @result&.errors
    end # method errors

    def failure!
      @result&.failure!
    end # method failure!

    def halt!
      @result&.halt!
    end # method halt!

    def merge_errors result, other
      return unless other.respond_to?(:errors)

      result.errors += other.errors
    end # method merge_errors

    def merge_results result, other
      if value_is_result?(other)
        result.value = other.value

        merge_errors(result, other)
      else
        result.value = other
      end # if-else

      result
    end # method merge_results

    def process *_args
      raise NotImplementedError, nil, caller(1..-1)
    end # method process

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

    def success!
      @result&.success!
    end # method success!

    def value_is_result? value
      value.respond_to?(:value) && value.respond_to?(:success?)
    end # method value
  end # class
end # module
