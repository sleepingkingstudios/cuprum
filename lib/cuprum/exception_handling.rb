# frozen_string_literal: true

require 'cuprum/errors/uncaught_exception'

module Cuprum
  # Utility module for handling uncaught exceptions in commands.
  #
  # This functionality can be temporarily disabled by setting the
  # ENV['CUPRUM_RERAISE_EXCEPTIONS'] flag; this can be used to debug issues when
  # testing commands.
  #
  # @example
  #   class UnsafeCommand < Cuprum::Command
  #     private
  #
  #     def process
  #       raise 'Something went wrong.'
  #     end
  #   end
  #
  #   class SafeCommand < UnsafeCommand
  #     include Cuprum::ExceptionHandling
  #   end
  #
  #   UnsafeCommand.new.call
  #   #=> raises a StandardError
  #
  #   result = SafeCommand.new.call
  #   #=> a Cuprum::Result
  #   result.error
  #   #=> a Cuprum::Errors::UncaughtException error.
  #   result.error.message
  #   #=> 'uncaught exception in SafeCommand -' \
  #   #   ' StandardError: Something went wrong.'
  module ExceptionHandling
    # Wraps the #call method with a rescue clause matching any StandardError.
    #
    # If a StandardError or subclass thereof is raised and not caught by #call,
    # then ExceptionHandling will rescue the exception and return a failing
    # Cuprum::Result with a Cuprum::Errors::UncaughtException error.
    #
    # @return [Cuprum::Result] the result of calling the superclass method, or
    #   a failing result if a StandardError is raised.
    #
    # @see Cuprum::Processing#call
    #
    # @raise StandardError if an exception is raised and the
    #   ENV['CUPRUM_RERAISE_EXCEPTIONS'] flag is set.
    def call(*args, **kwargs, &block)
      super
    rescue StandardError => exception
      raise exception if ENV['CUPRUM_RERAISE_EXCEPTIONS']

      error = Cuprum::Errors::UncaughtException.new(
        exception: exception,
        message:   "uncaught exception in #{self.class.name} - "
      )
      failure(error)
    end
  end
end
