require 'cuprum/chaining'
require 'cuprum/currying'
require 'cuprum/processing'

module Cuprum
  # Functional object that encapsulates a business logic operation with a
  # consistent interface and tracking of result value and status.
  #
  # A Command can be defined either by passing a block to the constructor, or
  # by defining a subclass of Command and implementing the #process method.
  #
  # @example A Command with a block
  #   double_command = Cuprum::Command.new { |int| 2 * int }
  #   result         = double_command.call(5)
  #
  #   result.value #=> 10
  #
  # @example A Command subclass
  #   class MultiplyCommand < Cuprum::Command
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
  #   triple_command = MultiplyCommand.new(3)
  #   result         = command_command.call(5)
  #
  #   result.value #=> 15
  #
  # @example A Command with an error state
  #   class DivideCommand < Cuprum::Command
  #     def initialize divisor
  #       @divisor = divisor
  #     end # constructor
  #
  #     private
  #
  #     def process int
  #       if @divisor.zero?
  #         return Cuprum::Result.new(error: 'errors.messages.divide_by_zero')
  #       end
  #
  #       int / @divisor
  #     end # method process
  #   end # class
  #
  #   halve_command = DivideCommand.new(2)
  #   result        = halve_command.call(10)
  #
  #   result.error #=> nil
  #   result.value #=> 5
  #
  #   divide_command = DivideCommand.new(0)
  #   result         = divide_command.call(10)
  #
  #   result.error #=> 'errors.messages.divide_by_zero'
  #   result.value #=> nil
  #
  # @example Command Chaining
  #   class AddCommand < Cuprum::Command
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
  #   double_and_add_one = MultiplyCommand.new(2).chain(AddCommand.new(1))
  #   result             = double_and_add_one(5)
  #
  #   result.value #=> 5
  #
  # @example Conditional Chaining
  #   class EvenCommand < Cuprum::Command
  #     private
  #
  #     def process int
  #       return int if int.even?
  #
  #       Cuprum::Errors.new(error: 'errors.messages.not_even')
  #     end # method process
  #   end # class
  #
  #   # The next step in a Collatz sequence is determined as follows:
  #   # - If the number is even, divide it by 2.
  #   # - If the number is odd, multiply it by 3 and add 1.
  #   collatz_command =
  #     EvenCommand.new.
  #       chain(DivideCommand.new(2), :on => :success).
  #       chain(
  #         MultiplyCommand.new(3).chain(AddCommand.new(1),
  #         :on => :failure
  #       )
  #
  #   result = collatz_command.new(5)
  #   result.value #=> 16
  #
  #   result = collatz_command.new(16)
  #   result.value #=> 8
  #
  # @see Cuprum::Chaining
  # @see Cuprum::Processing
  class Command
    include Cuprum::Processing
    include Cuprum::Chaining
    include Cuprum::Currying

    # Returns a new instance of Cuprum::Command.
    #
    # @yield [*arguments, **keywords, &block] If a block is given, the
    #   #call method will wrap the block and set the result #value to the return
    #   value of the block. This overrides the implementation in #process, if
    #   any.
    def initialize &implementation
      return unless implementation

      define_singleton_method :process, &implementation

      singleton_class.send(:private, :process)
    end # method initialize
  end # class
end # module
