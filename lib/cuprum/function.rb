# lib/cuprum/function.rb

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
      Cuprum::Result.new.tap do |result|
        @errors = result.errors

        result.value = process(*args, &block)

        @errors = nil
      end # tap
    end # method call

    private

    attr_reader :errors

    def process *_args
      raise NotImplementedError, nil, caller(1..-1)
    end # method process
  end # class
end # module
