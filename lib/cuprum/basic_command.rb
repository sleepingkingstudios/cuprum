require 'cuprum/not_implemented_error'

module Cuprum
  # Functional object that encapsulates a business logic operation with a
  # standardized interface and returns a result object.
  class BasicCommand
    # Returns a new instance of Cuprum::BasicCommand.
    #
    # @yield [*arguments, **keywords, &block] If a block is given, the
    #   #call method will wrap the block and set the result #value to the return
    #   value of the block. This overrides the implementation in #process, if
    #   any.
    def initialize &implementation
      define_singleton_method :process, &implementation if implementation
    end # method initialize

    # Returns a nonnegative integer for commands that take a fixed number of
    # arguments. For commands that take a variable number of arguments, returns
    # -n-1, where n is the number of required arguments.
    #
    # @return [Integer] The number of arguments.
    def arity
      method(:process).arity
    end # method arity

    # @overload call(*arguments, **keywords, &block)
    #   Executes the logic encoded in the constructor block, or the #process
    #   method if no block was passed to the constructor, and returns a
    #   Cuprum::Result object with the return value of the block or #process,
    #   the success or failure status, and any errors generated.
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
    #   @raise [Cuprum::NotImplementedError] Unless a block was passed to the
    #     constructor or the #process method was overriden by a Command
    #     subclass.
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
    # Generates an empty errors object. When the function is called, the result
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

    # :nocov:
    def humanize_list list, empty_value: ''
      return empty_value if list.size.zero?

      return list.first.to_s if list.size == 1

      return "#{list.first} and #{list.last}" if list.size == 2

      "#{list[0...-1].join ', '}, and #{list.last}"
    end # method humanize_list
    # :nocov:

    def merge_results result, other
      if value_is_result?(other)
        return result if result == other

        Cuprum.warn(result_not_empty_warning) unless result.empty?

        other.to_result
      else
        result.value = other

        result
      end # if-else
    end # method merge_results

    # @!visibility public
    # @overload process(*arguments, **keywords, &block)
    #   The implementation of the function, to be executed when the #call method
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

    def result_not_empty_warning # rubocop:disable Metrics/MethodLength
      warnings = []

      unless @result.errors.empty?
        warnings << "there were already errors #{@result.errors.inspect}"
      end # unless

      status = @result.send(:status)
      unless status.nil?
        warnings << "the status was set to #{status.inspect}"
      end # unless

      if @result.halted?
        warnings << 'the function was halted'
      end # if

      message = '#process returned a result, but '
      message <<
        humanize_list(warnings, :empty_value => 'the result was not empty')

      message
    end # method result_not_empty_warning

    # @!visibility public
    #
    # Marks the current result as passing. Calling #success? on the returned
    # result object will evaluate to true, whether or not the result has any
    # errors.
    #
    # @see Cuprum::Result#success!.
    #
    # @note This is a private method, and only available when executing the
    #   function implementation as defined in the constructor block or the
    #   #process method.
    def success!
      @result&.success!
    end # method success!

    def value_is_result? value
      value.respond_to?(:value) && value.respond_to?(:success?)
    end # method value
  end # class
end # module
