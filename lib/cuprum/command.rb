# frozen_string_literal: true

require 'cuprum/currying'
require 'cuprum/processing'
require 'cuprum/steps'

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
  #     end
  #
  #     private
  #
  #     def process int
  #       int * @multiplier
  #     end
  #   end
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
  #     end
  #
  #     private
  #
  #     def process int
  #       if @divisor.zero?
  #         return Cuprum::Result.new(error: 'errors.messages.divide_by_zero')
  #       end
  #
  #       int / @divisor
  #     end
  #   end
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
  # @see Cuprum::Processing
  class Command
    include Cuprum::Processing
    include Cuprum::Currying
    include Cuprum::Steps

    # Returns a new instance of Cuprum::Command.
    #
    # @yield [*arguments, **keywords, &block] If a block is given, the
    #   #call method will wrap the block and set the result #value to the return
    #   value of the block. This overrides the implementation in #process, if
    #   any.
    def initialize(&implementation)
      return unless implementation

      define_singleton_method :process, &implementation

      singleton_class.send(:private, :process)
    end

    def call(*args, **kwargs, &block)
      steps { super }
    end

    def to_proc
      @to_proc ||= lambda do |*args, **kwargs, &block|
        if kwargs.empty?
          call(*args, &block)
        else
          call(*args, **kwargs, &block)
        end
      end
    end
  end
end
