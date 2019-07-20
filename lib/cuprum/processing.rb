# frozen_string_literal: true

require 'cuprum/errors/command_not_implemented'

module Cuprum
  # Functional implementation for creating a command object. Cuprum::Processing
  # defines a #call method, which performs the implementation defined by
  # #process and returns an instance of Cuprum::Result.
  #
  # @example Defining a command with Cuprum::Processing.
  #   class AdderCommand
  #     include Cuprum::Processing
  #
  #     def initialize addend
  #       @addend = addend
  #     end
  #
  #     private
  #
  #     def process int
  #       int + addend
  #     end
  #   end
  #
  #   adder  = AdderCommand.new(2)
  #   result = adder.call(3)
  #   #=> an instance of Cuprum::Result
  #   result.value    #=> 5
  #   result.success? #=> true
  #
  # @example Defining a command with error handling.
  #   class SquareRootCommand
  #     include Cuprum::Processing
  #
  #     private
  #
  #     def process value
  #       if value.negative?
  #         return Cuprum::Result.new(error: 'value cannot be negative')
  #       end
  #
  #       Math.sqrt(value)
  #     end
  #   end
  #
  #   result = SquareRootCommand.new.call(2)
  #   result.value    #=> 1.414
  #   result.success? #=> true
  #   result.failure? #=> false
  #   result.error    #=> nil
  #
  #   result = SquareRootCommand.new.call(-1)
  #   result.value    #=> nil
  #   result.success? #=> false
  #   result.failure? #=> true
  #   result.error    #=> 'value cannot be negative'
  #
  # @see Cuprum::Command
  module Processing
    # Returns a nonnegative integer for commands that take a fixed number of
    # arguments. For commands that take a variable number of arguments, returns
    # -n-1, where n is the number of required arguments.
    #
    # @return [Integer] The number of arguments.
    def arity
      method(:process).arity
    end

    # @overload call(*arguments, **keywords, &block)
    #   Executes the command implementation and returns a Cuprum::Result or
    #   compatible object.
    #
    #   Each time #call is invoked, the object performs the following steps:
    #
    #   1. The #process method is called, passing the arguments, keywords, and
    #      block that were passed to #call.
    #   2. If the value returned by #process is a Cuprum::Result or compatible
    #      object, that result is directly returned by #call.
    #   3. Otherwise, the value returned by #process will be wrapped in a
    #      successful result, which will be returned by #call.
    #
    #   @param arguments [Array] Arguments to be passed to the implementation.
    #
    #   @param keywords [Hash] Keywords to be passed to the implementation.
    #
    #   @return [Cuprum::Result] The result object for the command.
    #
    #   @yield If a block argument is given, it will be passed to the
    #     implementation.
    def call(*args, &block)
      process_with_result(build_result, *args, &block)
    end

    private

    # @return [Cuprum::Result] The current result. Only available while #process
    #   is being called.
    attr_reader :result

    def build_result(value = nil, **options)
      Cuprum::Result.new(value: value, **options)
    end

    def merge_results(_result, other)
      if value_is_result?(other)
        other.to_cuprum_result
      else
        build_result(other)
      end
    end

    # @!visibility public
    # @overload process(*arguments, **keywords, &block)
    #   The implementation of the command, to be executed when the #call method
    #   is called. If #process returns a result, that result will be returned by
    #   #call; otherwise, the value returned by #process will be wrapped in a
    #   successful Cuprum::Result object. This method should not be called
    #   directly.
    #
    #   @param arguments [Array] The arguments, if any, passed from #call.
    #
    #   @param keywords [Hash] The keywords, if any, passed from #call.
    #
    #   @yield The block, if any, passed from #call.
    #
    #   @return [Object] the value of the result object to be returned by #call.
    #
    # @note This is a private method.
    def process(*_args)
      error = Cuprum::Errors::CommandNotImplemented.new(command: self)

      build_result(error: error)
    end

    def process_with_result(result, *args, &block)
      @result = result
      value   = process(*args, &block)

      merge_results(result, value)
    ensure
      @result = nil
    end

    def value_is_result?(value)
      value.respond_to?(:to_cuprum_result)
    end
  end
end
