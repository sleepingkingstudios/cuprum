require 'cuprum/result'

module Cuprum
  # Functional object that encapsulates a business logic operation with a
  # consistent interface and tracking of result value and status.
  #
  # A Function can be defined either by passing a block to the constructor, or
  # by defining a subclass of Function and implementing the #process method.
  #
  # @example A Function with a block
  #   double_function = Function.new { |int| 2 * int }
  #   result          = double_function.call(5)
  #
  #   result.value #=> 10
  #
  # @example A Function subclass
  #   class MultiplyFunction
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
  #   class DivideFunction
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

    # @overload call(*arguments, *keywords, &block)
    #   Executes the logic encoded in the constructor block, or the #process
    #   method if no block was passed to the constructor.
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
    #   @raise [NotImplementedError] unless a block was passed to the
    #     constructor or the #process method was overriden by a Function
    #     subclass.
    def call *args, &block
      call_chained_functions do
        Cuprum::Result.new.tap do |result|
          @errors = result.errors

          result.value = process(*args, &block)

          @errors = nil
        end # tap
      end # call_chained_functions
    end # method call

    # Registers a function or block to run after the current function, or after
    # the last chained function if the current function already has one or more
    # chained function(s). This creates and modifies a copy of the current
    # function.
    #
    # @overload chain(function)
    #   The function will be passed the #value of the previous function result
    #   as its parameter, and the result of the chained function will be
    #   returned (or passed to the next chained function, if any).
    #
    #   @param function [Cuprum::Function] The function to call after the
    #     current or last chained function.
    #
    # @overload chain(&block)
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
    # @return [Cuprum::Function] the chained function.
    def chain function = nil, &block
      proc = block ? block : ->(result) { function.call(result) }

      clone.tap do |fn|
        fn.chained_functions << { :proc => proc }
      end # tap
    end # method chain

    protected

    def call_chained_functions
      chained_functions.reduce(yield) do |result, hsh|
        value = hsh.fetch(:proc).call(result)

        value_is_result?(value) ? value : result
      end # reduce
    end # method call_chained_functions

    def chained_functions
      @chained_functions ||= []
    end # method chained_functions

    private

    attr_reader :errors

    def process *_args
      raise NotImplementedError, nil, caller(1..-1)
    end # method process

    def value_is_result? value
      value.respond_to?(:value) && value.respond_to?(:success?)
    end # method value
  end # class
end # module
