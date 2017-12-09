require 'cuprum'

module Cuprum
  # Mixin to implement command chaining functionality for a command class.
  # Chaining commands allows you to define complex logic by composing it from
  # simpler commands, including branching logic and error handling.
  #
  # @see Cuprum::Command
  module Chaining
    # Creates a copy of the first command, and then chains the given command or
    # block to execute after the first command's implementation. When #call is
    # executed, each chained command will be called with the previous result
    # value, and its result property will be set to the previous result. The
    # return value will be wrapped in a result and returned or yielded to the
    # next block.
    #
    # @return [Cuprum::Chaining] A copy of the command, with the chained
    #   command.
    #
    # @see #yield_result
    #
    # @overload chain(command, on: nil)
    #   @param command [Cuprum::Command] The command to chain.
    #
    #   @param on [Symbol] Sets a condition on when the chained block can run,
    #     based on the previous result. Valid values are :success, :failure, and
    #     :always. If the value is :success, the block will be called only if
    #     the previous result succeeded and is not halted. If the value is
    #     :failure, the block will be called only if the previous result failed
    #     and is not halted. If the value is :always, the block will be called
    #     regardless of the previous result status, even if the previous result
    #     is halted. If no value is given, the command will run whether the
    #     previous command was a success or a failure, but not if the command
    #     chain has been halted.
    #
    # @overload chain(on: nil) { |value| }
    #   Creates an anonymous command from the given block. The command will be
    #   passed the value of the previous result.
    #
    #   @param on [Symbol] Sets a condition on when the chained block can run,
    #     based on the previous result. Valid values are :success, :failure, and
    #     :always. If the value is :success, the block will be called only if
    #     the previous result succeeded and is not halted. If the value is
    #     :failure, the block will be called only if the previous result failed
    #     and is not halted. If the value is :always, the block will be called
    #     regardless of the previous result status, even if the previous result
    #     is halted. If no value is given, the command will run whether the
    #     previous command was a success or a failure, but not if the command
    #     chain has been halted.
    #
    #   @yieldparam value [Object] The value of the previous result.
    def chain command = nil, on: nil, &block
      command ||= Cuprum::Command.new(&block)
      chained = ->(result) { command.process_with_result(result, result.value) }

      clone.tap do |fn|
        fn.chained_procs <<
          {
            :proc => chained,
            :on   => on
          } # end hash
      end # tap
    end # method chain

    # Shorthand for command.chain(:on => :failure). Creates a copy of the first
    # command, and then chains the given command or block to execute after the
    # first command's implementation, but only if the previous command is
    # failing.
    #
    # @return [Cuprum::Chaining] A copy of the command, with the chained
    #   command.
    #
    # @see #chain
    #
    # @overload failure(command)
    #   @param command [Cuprum::Command] The command to chain.
    #
    # @overload failure() { |value| }
    #   Creates an anonymous command from the given block. The command will be
    #   passed the value of the previous result.
    #
    #   @yieldparam value [Object] The value of the previous result.
    def failure command = nil, &block
      chain(command, :on => :failure, &block)
    end # method failure

    # Shorthand for command.chain(:on => :success). Creates a copy of the first
    # command, and then chains the given command or block to execute after the
    # first command's implementation, but only if the previous command is
    # failing.
    #
    # @return [Cuprum::Chaining] A copy of the command, with the chained
    #   command.
    #
    # @see #chain
    #
    # @overload success(command)
    #   @param command [Cuprum::Command] The command to chain.
    #
    # @overload success() { |value| }
    #   Creates an anonymous command from the given block. The command will be
    #   passed the value of the previous result.
    #
    #   @yieldparam value [Object] The value of the previous result.
    def success command = nil, &block
      chain(command, :on => :success, &block)
    end # method success

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

    # Creates a copy of the command, and then chains the block to execute after
    # the command implementation. When #call is executed, each chained block
    # will be yielded the previous result, and the return value wrapped in a
    # result and returned or yielded to the next block.
    #
    # @param on [Symbol] Sets a condition on when the chained block can run,
    #   based on the previous result. Valid values are :success, :failure, and
    #   :always. If the value is :success, the block will be called only if the
    #   previous result succeeded and is not halted. If the value is :failure,
    #   the block will be called only if the previous result failed and is not
    #   halted. If the value is :always, the block will be called regardless of
    #   the previous result status, even if the previous result is halted. If no
    #   value is given, the command will run whether the previous command was a
    #   success or a failure, but not if the command chain has been halted.
    #
    # @yieldparam result [Cuprum::Result] The #result of the previous command.
    #
    # @return [Cuprum::Chaining] A copy of the command, with the chained block.
    #
    # @see #tap_result
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

    def process_with_result *args, &block
      yield_chain(super)
    end # method call

    private

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
