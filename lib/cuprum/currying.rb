# frozen_string_literal: true

require 'cuprum'

module Cuprum
  # Implements partial application for command objects.
  #
  # Partial application (more commonly referred to, if imprecisely, as currying)
  # refers to fixing some number of arguments to a function, resulting in a
  # function with a smaller number of arguments.
  #
  # In Cuprum's case, a curried (partially applied) command takes an original
  # command and pre-defines some of its arguments. When the curried command is
  # called, the predefined arguments and/or keywords will be combined with the
  # arguments passed to #call.
  #
  # @example Currying Arguments
  #   # Our base command takes two arguments.
  #   say_command = Cuprum::Command.new do |greeting, person|
  #     "#{greeting}, #{person}!"
  #   end
  #   say_command.call('Hello', 'world')
  #   #=> returns a result with value 'Hello, world!'
  #
  #   # Next, we create a curried command. This sets the first argument to
  #   # always be 'Greetings', so our curried command only takes one argument,
  #   # namely the name of the person being greeted.
  #   greet_command = say_command.curry('Greetings')
  #   greet_command.call('programs')
  #   #=> returns a result with value 'Greetings, programs!'
  #
  #   # Here, we are creating a curried command that passes both arguments.
  #   # Therefore, our curried command does not take any arguments.
  #   recruit_command = say_command.curry('Greetings', 'starfighter')
  #   recruit_command.call
  #   #=> returns a result with value 'Greetings, starfighter!'
  #
  # @example Currying Keywords
  #   # Our base command takes two keywords: a math operation and an array of
  #   # integers.
  #   math_command = Cuprum::Command.new do |operands:, operation:|
  #     operations.reduce(&operation)
  #   end
  #   math_command.call(operands: [2, 2], operation: :+)
  #   #=> returns a result with value 4
  #
  #   # Our curried command still takes two keywords, but now the operation
  #   # keyword is optional. It now defaults to :*, for multiplication.
  #   multiply_command = math_command.curry(operation: :*)
  #   multiply_command.call(operands: [3, 3])
  #   #=> returns a result with value 9
  module Currying
    autoload :CurriedCommand, 'cuprum/currying/curried_command'

    # Returns a CurriedCommand that wraps this command with pre-set arguments.
    #
    # When the curried command is called, the predefined arguments and/or
    # keywords will be combined with the arguments passed to #call.
    #
    # The original command is unchanged.
    #
    # @param arguments [Array] The arguments to pass to the curried command.
    # @param keywords [Hash] The keywords to pass to the curried command.
    #
    # @return [Cuprum::Currying::CurriedCommand] the curried command.
    #
    # @see Cuprum::Currying::CurriedCommand#call
    def curry(*arguments, **keywords, &block)
      return self if arguments.empty? && keywords.empty? && block.nil?

      Cuprum::Currying::CurriedCommand.new(
        arguments:,
        block:,
        command:   self,
        keywords:
      )
    end
  end
end
