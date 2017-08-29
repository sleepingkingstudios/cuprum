require 'cuprum/function'

module Cuprum
  # Functional object that with syntactic sugar for tracking the last result.
  #
  # An Operation is like a Function, but with an additional trick of tracking
  # its own most recent execution result. This allows us to simplify some
  # conditional logic, especially boilerplate code used to interact with
  # frameworks.
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
  #     end # if-else
  #   end # create
  #
  # Like a Function, an Operation can be defined directly by passing an
  # implementation block to the constructor or by creating a subclass that
  # overwrites the #process method.
  #
  # @see Cuprum::Function
  class Operation < Cuprum::Function
    # @return [Cuprum::Result] The result from the most recent call of the
    #   operation.
    attr_reader :result

    # (see Cuprum::Function#call)
    def call *args, &block
      reset! if called? # Clear reference to most recent result.

      @result = super
    end # method call

    # @return [Boolean] true if the operation has been called and has a
    #   reference to the most recent result; otherwise false.
    def called?
      !result.nil?
    end # method called?

    # @return [Array] the errors from the most recent result, or nil if the
    #   operation has not been called.
    def errors
      super || (called? ? result.errors : nil)
    end # method errors

    # @return [Boolean] true if the most recent result had errors, or false if
    #   the most recent result had no errors or if the operation has not been
    #   called.
    def failure?
      called? ? result.failure? : false
    end # method success?

    # @return [Boolean] true if the most recent was halted, otherwise false.
    def halted?
      called? ? result.halted? : false
    end # method halted?

    # Clears the reference to the most recent call of the operation, if any.
    # This allows the result and any referenced data to be garbage collected.
    # Use this method to clear any instance variables or state internal to the
    # operation (an operation should never have external state apart from the
    # last result).
    #
    # If the operation cannot be run more than once, this method should raise an
    # error.
    def reset!
      @result = nil
    end # method reset

    # @return [Boolean] true if the most recent result had no errors, or false
    #   if the most recent result had errors or if the operation has not been
    #   called.
    def success?
      called? ? result.success? : false
    end # method success?

    # @return [Object] the value of the most recent result, or nil if the
    #   operation has not been called.
    def value
      called? ? result.value : nil
    end # method value
  end # class
end # module
