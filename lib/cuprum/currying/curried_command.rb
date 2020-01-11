# frozen_string_literal: true

require 'cuprum/currying'

module Cuprum::Currying
  # @todo Document Cuprum::Currying::CurriedCommand.
  #
  # A CurriedCommand wraps another command and passes preset args to #call.
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
  #   greet_command =
  #     Cuprum::CurriedCommand.new(
  #       arguments: ['Greetings'],
  #       command:   say_command
  #     )
  #   greet_command.call('programs')
  #   #=> returns a result with value 'Greetings, programs!'
  #
  #   # Here, we are creating a curried command that passes both arguments.
  #   # Therefore, our curried command does not take any arguments.
  #   recruit_command =
  #     Cuprum::CurriedCommand.new(
  #       arguments: ['Greetings', 'starfighter'],
  #       command:   say_command
  #     )
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
  #   multiply_command =
  #     Cuprum::CurriedCommand.new(
  #       command:  math_command,
  #       keywords: { operation: :* }
  #     )
  #   multiply_command.call(operands: [3, 3])
  #   #=> returns a result with value 9
  class CurriedCommand < Cuprum::Command
    # @param arguments [Array] The arguments to pass to the curried command.
    # @param command [Cuprum::Command] The original command to curry.
    # @param keywords [Hash] The keywords to pass to the curried command.
    def initialize(arguments: [], command:, keywords: {})
      @arguments = arguments
      @command   = command
      @keywords  = keywords
    end

    # @!method call(*args, **kwargs)
    #   Merges the arguments and keywords and calls the wrapped command.
    #
    #   First, the arguments array is created starting with the :arguments
    #   passed to #initialize. Any positional arguments passed directly to #call
    #   are then appended.
    #
    #   Second, the keyword arguments are created by merging the keywords passed
    #   directly into #call into the keywods passed to #initialize. This means
    #   that if a key is passed in both places, the value passed into #call will
    #   take precedence.
    #
    #   Finally, the merged arguments and keywords are passed into the original
    #   command's #call method.
    #
    #   @param args [Array] Additional arguments to pass to the curried command.
    #   @param kwargs [Hash] Additional keywords to pass to the curried command.
    #
    #   @return [Cuprum::Result]
    #
    #   @see Cuprum::Processing#call

    # @return [Array] the arguments to pass to the curried command.
    attr_reader :arguments

    # @return [Cuprum::Command] the original command to curry.
    attr_reader :command

    # @return [Hash] the keywords to pass to the curried command.
    attr_reader :keywords

    private

    def process(*args, **kwargs, &block)
      args   = [*arguments, *args]
      kwargs = keywords.merge(kwargs)
      args << kwargs unless kwargs.empty?

      command.call(*args, &block)
    end
  end
end
