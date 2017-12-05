require 'cuprum'

module Cuprum
  # Mixin to implement command chaining functionality for a command class.
  # Chaining commands allows you to define complex logic by composing it from
  # simpler commands, including branching logic and error handling.
  #
  # @see Cuprum::Command
  module Chaining
    # (see Cuprum::BasicCommand#call)
    def call *args, &block
      yield_chain(super)
    end # method call

    # Registers a command or block to run after the current command, or after
    # the last chained command if the current command already has one or more
    # chained command(s). This creates and modifies a copy of the current
    # command.
    #
    # @param on [Symbol] Sets a condition on when the chained command can run,
    #   based on the status of the previous command. Valid values are :success,
    #   :failure, and :always. A value of :success will constrain the command
    #   to run only if the previous command succeeded. A value of :failure will
    #   constrain the command to run only if the previous command failed. A
    #   value of :always will ensure the command is always run, even if the
    #   command chain has been halted. If no value is given, the command will
    #   run whether the previous command was a success or a failure, but not if
    #   the command chain has been halted.
    #
    # @overload chain(command, on: nil)
    #   The command will be passed the #value of the previous command result
    #   as its parameter, and the result of the chained command will be
    #   returned (or passed to the next chained command, if any).
    #
    #   @param command [Cuprum::Command] The command to call after the
    #     current or last chained command.
    #
    # @overload chain(on: :nil, &block)
    #   The block will be passed the #result of the previous command as its
    #   parameter. If your use case depends on the status of the previous
    #   command or on any errors generated, use the block form of #chain.
    #
    #   If the block returns a Cuprum::Result (or an object responding to #value
    #   and #success?), the block result will be returned (or passed to the next
    #   chained command, if any). If the block returns any other value
    #   (including nil), the #result of the previous command will be returned
    #   or passed to the next command.
    #
    #   @yieldparam result [Cuprum::Result] The #result of the previous
    #     command.
    #
    # @return [Cuprum::Command] The chained command.
    def chain command = nil, on: nil, &block
      yield_result(:on => on, &chain_command(command || block))
    end # method chain

    # Shorthand for function.chain(:on => :failure). Registers a function or
    # block to run after the current function. The chained function will only
    # run if the previous function was unsuccessfully run.
    #
    # @overload else(function)
    #
    #   @param function [Cuprum::Command] The function to call after the
    #     current or last chained function.
    #
    # @overload else(&block)
    #
    #   @yieldparam result [Cuprum::Result] The #result of the previous
    #     function.
    #
    # @return [Cuprum::Command] The chained function.
    #
    # @see #chain
    def else function = nil, &block
      chain(function, :on => :failure, &block)
    end # method else

    # As #yield_result, but always returns the previous result when the block is
    # called. The return value of the block is discarded.
    #
    # @param (see #yield_result)
    #
    # @yieldparam result [Cuprum::Result] The #result of the previous command.
    #
    # @return (see #yield_result)
    #
    # @see #yield_result
    def tap_result on: nil, &block
      tapped = ->(result) { result.tap { block.call(result) } }

      clone.tap do |fn|
        fn.chained_procs <<
          {
            :proc => tapped,
            :on   => on
          } # end hash
      end # tap
    end # method tap_result

    # Shorthand for function.chain(:on => :success). Registers a function or
    # block to run after the current function. The chained function will only
    # run if the previous function was successfully run.
    #
    # @overload then(function)
    #
    #   @param function [Cuprum::Command] The function to call after the
    #     current or last chained function.
    #
    # @overload then(&block)
    #
    #   @yieldparam result [Cuprum::Result] The #result of the previous
    #     function.
    #
    # @return [Cuprum::Command] The chained function.
    #
    # @see #chain
    def then function = nil, &block
      chain(function, :on => :success, &block)
    end # method then

    def yield_result on: nil, &block
      clone.tap do |fn|
        fn.chained_procs <<
          {
            :proc => block,
            :on   => on
          } # end hash
      end # tap
    end # method yield_result

    protected

    def chained_procs
      @chained_procs ||= []
    end # method chained_procs

    private

    def chain_command command
      lambda do |result|
        value = command.call(result)

        value_is_result?(value) ? value.to_result : result
      end # lambda
    end # method chain_command

    def skip_chained_proc? last_result, on:
      return false if on == :always

      return true if last_result.respond_to?(:halted?) && last_result.halted?

      case on
      when :success
        !last_result.success?
      when :failure
        !last_result.failure?
      end # case
    end # method skip_chained_proc?

    def yield_chain first_result
      chained_procs.reduce(first_result) do |result, hsh|
        next result if skip_chained_proc?(result, :on => hsh[:on])

        value = hsh.fetch(:proc).call(result)

        if value_is_result?(value)
          value.to_result
        else
          build_result(value, :errors => build_errors)
        end # if-else
      end # reduce
    end # method yield_chain
  end # module
end # modue
