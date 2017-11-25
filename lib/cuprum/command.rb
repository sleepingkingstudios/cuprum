require 'cuprum/basic_command'
require 'cuprum/chaining'
require 'cuprum/not_implemented_error'
require 'cuprum/result'

module Cuprum
  # Functional object that encapsulates a business logic operation with a
  # consistent interface and tracking of result value and status.
  #
  # A Command can be defined either by passing a block to the constructor, or
  # by defining a subclass of Command and implementing the #process method.
  #
  # @example A Command with a block
  #   double_function = Cuprum::Command.new { |int| 2 * int }
  #   result          = double_function.call(5)
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
  #   triple_function = MultiplyCommand.new(3)
  #   result          = triple_function.call(5)
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
  #   halve_function = DivideCommand.new(2)
  #   result         = halve_function.call(10)
  #
  #   result.errors #=> []
  #   result.value  #=> 5
  #
  #   function_with_errors = DivideCommand.new(0)
  #   result               = function_with_errors.call(10)
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
  # @example Conditional Chaining With #then And #else
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
  #   collatz_function =
  #     EvenCommand.new.
  #       then(DivideCommand.new(2)).
  #       else(MultiplyCommand.new(3).chain(AddCommand.new(1)))
  #
  #   result = collatz_function.new(5)
  #   result.value #=> 16
  #
  #   result = collatz_function.new(16)
  #   result.value #=> 8
  class Command < Cuprum::BasicCommand
    include Cuprum::Chaining
  end # class
end # module
