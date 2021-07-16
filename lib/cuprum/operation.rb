# frozen_string_literal: true

require 'cuprum/command'
require 'cuprum/errors/operation_not_called'

module Cuprum
  # Functional object with syntactic sugar for tracking the last result.
  #
  # An Operation is like a Command, but with two key differences. First, an
  # Operation retains a reference to the result object from the most recent time
  # the operation was called and delegates the methods defined by Cuprum::Result
  # to the most recent result. This allows a called Operation to replace a
  # Cuprum::Result in any code that expects or returns a result. Second, the
  # #call method returns the operation instance, rather than the result itself.
  #
  # These two features allow developers to simplify logic around calling and
  # using the results of operations, and reduce the need for boilerplate code
  # (particularly when using an operation as part of an existing framework,
  # such as inside of an asynchronous worker or a Rails controller action).
  #
  # @example
  #   def create
  #     operation = CreateBookOperation.new.call(book_params)
  #
  #     if operation.success?
  #       redirect_to(operation.value)
  #     else
  #       @book = operation.value
  #
  #       render :new
  #     end
  #   end
  #
  # Like a Command, an Operation can be defined directly by passing an
  # implementation block to the constructor or by creating a subclass that
  # overwrites the #process method.
  #
  # @see Cuprum::Command
  class Operation < Cuprum::Command
    # Module-based implementation of the Operation methods. Use this to convert
    # an already-defined command into an operation.
    #
    # @example
    #   class CustomOperation < CustomCommand
    #     include Cuprum::Operation::Mixin
    #   end
    module Mixin
      # @return [Cuprum::Result] The result from the most recent call of the
      #   operation.
      attr_reader :result

      # @overload call(*arguments, **keywords, &block)
      #   Executes the logic encoded in the constructor block, or the #process
      #   method if no block was passed to the constructor, and returns the
      #   operation object.
      #
      #   @param arguments [Array] Arguments to be passed to the implementation.
      #
      #   @param keywords [Hash] Keywords to be passed to the implementation.
      #
      #   @return [Cuprum::Operation] the called operation.
      #
      #   @yield If a block argument is given, it will be passed to the
      #     implementation.
      #
      # @see Cuprum::Command#call
      def call(*args, **kwargs, &block)
        reset! if called? # Clear reference to most recent result.

        @result = super

        self
      end

      # @return [Boolean] true if the operation has been called and has a
      #   reference to the most recent result; otherwise false.
      def called?
        !result.nil?
      end

      # @return [Object] the error (if any) from the most recent result, or nil
      #   if the operation has not been called.
      def error
        called? ? result.error : nil
      end

      # @return [Boolean] true if the most recent result had an error, or false
      #   if the most recent result had no error or if the operation has not
      #   been called.
      def failure?
        called? ? result.failure? : false
      end

      # Clears the reference to the most recent call of the operation, if any.
      # This allows the result and any referenced data to be garbage collected.
      # Use this method to clear any instance variables or state internal to the
      # operation (an operation should never have external state apart from the
      # last result).
      #
      # If the operation cannot be run more than once, this method should raise
      # an error.
      def reset!
        @result = nil
      end

      # @return [Symbol, nil] the status of the most recent result, or nil if
      #   the operation has not been called.
      def status
        called? ? result.status : nil
      end

      # @return [Boolean] true if the most recent result had no error, or false
      #   if the most recent result had an error or if the operation has not
      #   been called.
      def success?
        called? ? result.success? : false
      end

      # Returns the most result if the operation was previously called.
      # Otherwise, returns a failing result.
      #
      # @return [Cuprum::Result] the most recent result or failing result.
      def to_cuprum_result
        return result if result

        error = Cuprum::Errors::OperationNotCalled.new(operation: self)

        Cuprum::Result.new(error: error)
      end

      # @return [Object] the value of the most recent result, or nil if the
      #   operation has not been called.
      def value
        called? ? result.value : nil
      end
    end
    include Mixin

    # @!method call
    #   (see Cuprum::Operation::Mixin#call)

    # @!method called?
    #   (see Cuprum::Operation::Mixin#called?)

    # @!method error
    #   (see Cuprum::Operation::Mixin#error)

    # @!method failure?
    #   (see Cuprum::Operation::Mixin#failure?)

    # @!method reset!
    #   (see Cuprum::Operation::Mixin#reset!)

    # @!method result
    #   (see Cuprum::Operation::Mixin#result)

    # @!method success?
    #   (see Cuprum::Operation::Mixin#success?)

    # @!method to_cuprum_result
    #   (see Cuprum::Operation::Mixin#to_cuprum_result)

    # @!method value
    #   (see Cuprum::Operation::Mixin#value)
  end
end
