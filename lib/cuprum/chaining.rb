require 'cuprum'

module Cuprum
  # Mixin to implement command chaining functionality for a command class.
  # Chaining commands allows you to define complex logic by composing it from
  # simpler commands, including branching logic and error handling.
  #
  # @see Cuprum::Function
  module Chaining
    # (see Cuprum::BasicCommand#call)
    def call *args, &block
      call_chained_functions(super)
    end # method call

    # Registers a function or block to run after the current function, or after
    # the last chained function if the current function already has one or more
    # chained function(s). This creates and modifies a copy of the current
    # function.
    #
    # @param on [Symbol] Sets a condition on when the chained function can run,
    #   based on the status of the previous function. Valid values are :success,
    #   :failure, and :always. A value of :success will constrain the function
    #   to run only if the previous function succeeded. A value of :failure will
    #   constrain the function to run only if the previous function failed. A
    #   value of :always will ensure the function is always run, even if the
    #   function chain has been halted. If no value is given, the function will
    #   run whether the previous function was a success or a failure, but not if
    #   the function chain has been halted.
    #
    # @overload chain(function, on: nil)
    #   The function will be passed the #value of the previous function result
    #   as its parameter, and the result of the chained function will be
    #   returned (or passed to the next chained function, if any).
    #
    #   @param function [Cuprum::Function] The function to call after the
    #     current or last chained function.
    #
    # @overload chain(on: :nil, &block)
    #   The block will be passed the #result of the previous function as its
    #   parameter. If your use case depends on the status of the previous
    #   function or on any errors generated, use the block form of #chain.
    #
    #   If the block returns a Cuprum::Result (or an object responding to #value
    #   and #success?), the block result will be returned (or passed to the next
    #   chained function, if any). If the block returns any other value
    #   (including nil), the #result of the previous function will be returned
    #   or passed to the next function.
    #
    #   @yieldparam result [Cuprum::Result] The #result of the previous
    #     function.
    #
    # @return [Cuprum::Function] The chained function.
    def chain function = nil, on: nil, &block
      clone.tap do |fn|
        fn.chained_functions <<
          {
            :proc => convert_function_or_proc_to_proc(block || function),
            :on   => on
          } # end hash
      end # tap
    end # method chain

    # Shorthand for function.chain(:on => :failure). Registers a function or
    # block to run after the current function. The chained function will only
    # run if the previous function was unsuccessfully run.
    #
    # @overload else(function)
    #
    #   @param function [Cuprum::Function] The function to call after the
    #     current or last chained function.
    #
    # @overload else(&block)
    #
    #   @yieldparam result [Cuprum::Result] The #result of the previous
    #     function.
    #
    # @return [Cuprum::Function] The chained function.
    #
    # @see #chain
    def else function = nil, &block
      chain(function, :on => :failure, &block)
    end # method else

    # Shorthand for function.chain(:on => :success). Registers a function or
    # block to run after the current function. The chained function will only
    # run if the previous function was successfully run.
    #
    # @overload then(function)
    #
    #   @param function [Cuprum::Function] The function to call after the
    #     current or last chained function.
    #
    # @overload then(&block)
    #
    #   @yieldparam result [Cuprum::Result] The #result of the previous
    #     function.
    #
    # @return [Cuprum::Function] The chained function.
    #
    # @see #chain
    def then function = nil, &block
      chain(function, :on => :success, &block)
    end # method then

    protected

    def chained_functions
      @chained_functions ||= []
    end # method chained_functions

    private

    def call_chained_functions first_result
      chained_functions.reduce(first_result) do |result, hsh|
        next result if skip_chained_function?(result, :on => hsh[:on])

        value = hsh.fetch(:proc).call(result)

        convert_value_to_result(value) || result
      end # reduce
    end # method call_chained_functions

    def convert_function_or_proc_to_proc function_or_proc
      return function_or_proc if function_or_proc.is_a?(Proc)

      ->(result) { function_or_proc.call(result) }
    end # method convert_function_or_proc_to_proc

    def skip_chained_function? last_result, on:
      return false if on == :always

      return true if last_result.respond_to?(:halted?) && last_result.halted?

      case on
      when :success
        !last_result.success?
      when :failure
        !last_result.failure?
      end # case
    end # method skip_chained_function?
  end # module
end # modue
