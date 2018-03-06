require 'cuprum/chaining'
require 'cuprum/processing'
require 'cuprum/result_helpers'

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
  # @example A Command with errors
  #   class DivideCommand < Cuprum::Command
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
  #   halve_command = DivideCommand.new(2)
  #   result        = halve_command.call(10)
  #
  #   result.errors #=> []
  #   result.value  #=> 5
  #
  #   command_with_errors = DivideCommand.new(0)
  #   result              = command_with_errors.call(10)
  #
  #   result.errors #=> ['errors.messages.divide_by_zero']
  #   result.value  #=> nil
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
  #       errors << 'errors.messages.not_even' unless int.even?
  #
  #       int
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
  # @see Cuprum::ResultHelpers
  class Command
    include Cuprum::Processing
    include Cuprum::Chaining
    include Cuprum::ResultHelpers

    # Returns a new instance of Cuprum::Command.
    #
    # @yield [*arguments, **keywords, &block] If a block is given, the
    #   #call method will wrap the block and set the result #value to the return
    #   value of the block. This overrides the implementation in #process, if
    #   any.
    def initialize &implementation
      define_singleton_method :process, &implementation if implementation
    end # method initialize
  end # class
end # module
