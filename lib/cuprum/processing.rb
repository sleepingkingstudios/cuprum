require 'cuprum/not_implemented_error'
require 'cuprum/utils/result_not_empty_warning'

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
  #     end # constructor
  #
  #     private
  #
  #     def process int
  #       int + addend
  #     end # method process
  #   end # class AdderCommand
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
  #         result.errors << 'value cannot be negative'
  #
  #         return nil
  #       end # if
  #
  #       Math.sqrt(value)
  #     end # method process
  #   end # class
  #
  #   result = SquareRootCommand.new.call(2)
  #   result.value    #=> 1.414
  #   result.success? #=> true
  #   result.failure? #=> false
  #   result.errors   #=> []
  #
  #   result = SquareRootCommand.new.call(-1)
  #   result.value    #=> nil
  #   result.success? #=> false
  #   result.failure? #=> true
  #   result.errors   #=> ['value cannot be negative']
  #
  # @see Cuprum::Command
  module Processing
    VALUE_METHODS = %i[to_result value success?].freeze
    private_constant :VALUE_METHODS

    # Returns a nonnegative integer for commands that take a fixed number of
    # arguments. For commands that take a variable number of arguments, returns
    # -n-1, where n is the number of required arguments.
    #
    # @return [Integer] The number of arguments.
    def arity
      method(:process).arity
    end # method arity

    # @overload call(*arguments, **keywords, &block)
    #   Executes the command implementation and returns a Cuprum::Result or
    #   compatible object.
    #
    #   Each time #call is invoked, the object performs the following steps:
    #
    #   1. Creates a result object, typically an instance of Cuprum::Result.
    #      The result is assigned to the command as the private #result reader.
    #   2. The #process method is called, passing the arguments, keywords, and
    #      block that were passed to #call. The #process method can set errors,
    #      set the status, or halt the result via the #result reader method.
    #   3. If #process returns a result, that result is returned by #call.
    #      Otherwise, the return value of #process is assigned to the #value
    #      property of the result, and the result is returned by #call.
    #
    #   @param arguments [Array] Arguments to be passed to the implementation.
    #
    #   @param keywords [Hash] Keywords to be passed to the implementation.
    #
    #   @return [Cuprum::Result] The result object for the command.
    #
    #   @yield If a block argument is given, it will be passed to the
    #     implementation.
    #
    #   @raise [Cuprum::NotImplementedError] Unless the #process method was
    #     overriden.
    def call *args, &block
      result = build_result(nil, :errors => build_errors)

      process_with_result(result, *args, &block)
    end # method call

    private

    # @return [Cuprum::Result] The current result. Only available while #process
    #   is being called.
    attr_reader :result

    # @!visibility public
    #
    # Generates an empty errors object. When the command is called, the result
    # will have its #errors property initialized to the value returned by
    # #build_errors. By default, this is an array. If you want to use a custom
    # errors object type, override this method in a subclass.
    #
    # @return [Array] An empty errors object.
    def build_errors
      []
    end # method build_errors

    def build_result value, errors:
      Cuprum::Result.new(value, :errors => errors)
    end # method build_result

    def merge_results result, other
      if value_is_result?(other)
        return result if result == other

        warn_unless_empty!(result)

        other.to_result
      else
        result.value = other

        result
      end # if-else
    end # method merge_results

    # @!visibility public
    # @overload process(*arguments, **keywords, &block)
    #   The implementation of the command, to be executed when the #call method
    #   is called. Can add errors to or set the status of the result, and the
    #   value of the result will be set to the value returned by #process. Do
    #   not call this method directly.
    #
    #   @param arguments [Array] The arguments, if any, passed from #call.
    #
    #   @param keywords [Hash] The keywords, if any, passed from #call.
    #
    #   @yield The block, if any, passed from #call.
    #
    #   @return [Object] the value of the result object to be returned by #call.
    #
    #   @raise [Cuprum::NotImplementedError] Unless a block was passed to the
    #     constructor or the #process method was overriden by a Command
    #     subclass.
    #
    # @note This is a private method.
    def process *_args
      raise Cuprum::NotImplementedError, nil, caller(1..-1)
    end # method process

    def process_with_result result, *args, &block
      @result = result
      value   = process(*args, &block)

      merge_results(result, value)
    ensure
      @result = nil
    end # method process_with_result

    def value_is_result? value
      VALUE_METHODS.all? { |method_name| value.respond_to?(method_name) }
    end # method value

    def warn_unless_empty! result
      return unless result.respond_to?(:empty?) && !result.empty?

      not_empty = Cuprum::Utils::ResultNotEmptyWarning.new(result)

      Cuprum.warn(not_empty.message) if not_empty.warning?
    end # method warn_unless_empty!
  end # module
end # module