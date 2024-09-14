# frozen_string_literal: true

require 'sleeping_king_studios/tools/toolbox/subclass'

require 'cuprum/currying'
require 'cuprum/processing'
require 'cuprum/steps'

module Cuprum
  # Functional object that encapsulates a business logic operation or step.
  #
  # Using commands allows the developer to maintain a state or context, such as
  # by passing context into the constructor. It provides a consistent interface
  # by always returning a Cuprum::Result object, which tracks the status of the
  # command call, the returned value, and the error object (if any). Finally, as
  # a full-fledged Ruby object a Command can be passed around like any other
  # object, including returned from a method (or another Command) or passed in
  # as a parameter.
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
  #     def initialize(multiplier)
  #       @multiplier = multiplier
  #     end
  #
  #     private def process(int)
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
  #     def initialize(divisor)
  #       @divisor = divisor
  #     end
  #
  #     private def process(int)
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
    extend  SleepingKingStudios::Tools::Toolbox::Subclass
    include Cuprum::Processing
    include Cuprum::Currying
    include Cuprum::Steps

    # @!scope class

    # @!method subclass(*class_arguments, **class_keywords, &block)
    #   Creates a subclass with partially applied constructor parameters.
    #
    #   @param class_arguments [Array] the arguments, if any, to apply to the
    #     constructor. These arguments will be added before any args passed
    #     directly to the constructor.
    #   @param class_keywords [Hash] the keywords, if any, to apply to the
    #     constructor. These keywords will be added before any kwargs passed
    #     directly to the constructor.
    #
    #   @yield the block, if any, to pass to the constructor. This will be
    #     overriden by a block passed directly to the constructor.
    #
    #   @return [Class] the generated subclass.

    # @!scope instance

    # Returns a new instance of Cuprum::Command.
    #
    # @yield If a block is given, the block is used to define a private #process
    #   method. This overwrites any existing #process method. When the command
    #   is called, #process will be called internally and passed the parameters.
    #
    # @yieldparam arguments [Array] the arguments passed to #call.
    # @yieldparam keywords [Hash] the keywords passed to #call.
    # @yieldparam block [Proc, nil] the block passed to call, #if any.
    #
    # @yieldreturn [Cuprum::Result, Object] the returned result or object is
    #   converted to a Cuprum::Result and returned by #call.
    def initialize(&implementation)
      return unless implementation

      define_singleton_method :process, &implementation

      singleton_class.send(:private, :process)
    end

    # (see Cuprum::Processing#call)
    def call(*args, **kwargs, &)
      steps { super }
    end

    # Wraps the command in a proc.
    #
    # Calling the proc will call the command with the given arguments, keywords,
    # and block.
    #
    # @return [Proc] the wrapping proc.
    def to_proc
      command = self

      @to_proc ||= lambda do |*args, **kwargs, &block|
        if kwargs.empty?
          command.call(*args, &block)
        else
          command.call(*args, **kwargs, &block)
        end
      end
    end
  end
end
