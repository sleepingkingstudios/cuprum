# frozen_string_literal: true

require 'cuprum'

module Cuprum
  # Implements a wrapper around another command.
  #
  # A middleware command wraps the execution of another command, allowing the
  # developer to compose functionality without an explicit wrapper command.
  # Because the middleware is responsible for calling the wrapped command, it
  # has control over when that command is called, with what parameters, and how
  # the command result is handled.
  #
  # To use middleware, start by defining a middleware command. This can either
  # be a class that includes Cuprum::Middleware, or a command instance that
  # extends Cuprum::Middleware. Each middleware command's #process method takes
  # as its first argument the wrapped command. By convention, any additional
  # arguments and any keywords or a block are passed to the wrapped command, but
  # some middleware will override ths behavior.
  #
  # When defining #process, make sure to either call super or call the wrapped
  # command directly, unless the middleware is specifically intended not to call
  # the wrapped command under those circumstances.
  #
  # Middleware is powerful because it allows the developer to manipulate the
  # parameters passed to a command, add handling to a result, or even intercept
  # or override the command execution. These are some of the possible use cases
  # for middleware:
  #
  # - Injecting code before or after a command.
  # - Changing the parameters passed to a command.
  # - Adding behavior based on the command result.
  # - Overriding the command behavior based on the parameters.
  #
  # Middleware is loosely coupled, meaning that one middleware command can wrap
  # any number of other commands. One example would be logging middleware, which
  # could record when a command is called and with what parameters. For a more
  # involved example, consider authorization in a web application. If individual
  # actions are defined as commands, then a single authorization middleware
  # class could wrap each individual action, reducing both the testing burden
  # and the amount of code that must be maintained.
  #
  # @example Basic Middleware
  #   class ExampleCommand < Cuprum::Command
  #     private def process(**options)
  #       return failure(options[:error]) if options[:error]
  #
  #       "Options: #{options.inspect}"
  #     end
  #   end
  #
  #   class LoggingMiddleware < Cuprum::Command
  #     include Cuprum::Middleware
  #
  #     # The middleware injects a logging step before the wrapped command is
  #     # called. Notice that this middleware is generic, and can be used with
  #     # virtually any other command.
  #     private def process(next_command, *args, **kwargs)
  #       Logger.info("Calling command #{next_command.class}")
  #
  #       super
  #     end
  #   end
  #
  #   command    = Command.new { |**opts| "Called with #{opts.inspect}" }
  #   middleware = LoggingMiddleware.new
  #   result     = middleware.call(command, { id: 0 })
  #   #=> logs "Calling command ExampleCommand"
  #   result.value
  #   #=> "Options: { id: 0 }"
  #
  # @example Injecting Parameters
  #   class ApiMiddleware < Cuprum::Command
  #     include Cuprum::Middleware
  #
  #     # The middleware adds the :api_key to the parameters passed to the
  #     # command. If an :api_key keyword is passed, then the passed value will
  #     # take precedence.
  #     private def process(next_command, *args, **kwargs)
  #       super(next_command, *args, api_key: '12345', **kwargs)
  #     end
  #   end
  #
  #   command    = Command.new { |**opts| "Called with #{opts.inspect}" }
  #   middleware = LoggingMiddleware.new
  #   result     = middleware.call(command, { id: 0 })
  #   result.value
  #   #=> "Options: { id: 0, api_key: '12345' }"
  #
  # @example Handling Results
  #   class IgnoreFailure < Cuprum::Command
  #     include Cuprum::Middleware
  #
  #     # The middleware runs the command once. On a failing result, the
  #     # middleware discards the failing result and returns a result with a
  #     # value of nil.
  #     private def process(next_command, *args, **kwargs)
  #       result = super
  #
  #       return result if result.success?
  #
  #       success(nil)
  #     end
  #   end
  #
  #   command    = Command.new { |**opts| "Called with #{opts.inspect}" }
  #   middleware = LoggingMiddleware.new
  #   result     = middleware.call(command, { id: 0 })
  #   result.success?
  #   #=> true
  #   result.value
  #   #=> "Options: { id: 0, api_key: '12345' }"
  #
  #   error      = Cuprum::Error.new(message: 'Something went wrong.')
  #   result     = middleware.call(command, error: error)
  #   result.success?
  #   #=> true
  #   result.value
  #   #=> nil
  #
  # @example Flow Control
  #   class AuthenticationMiddleware < Cuprum::Command
  #     include Cuprum::Middleware
  #
  #     # The middleware finds the current user based on the given keywords. If
  #     # a valid user is found, the user is then passed on to the command.
  #     # If a user is not found, then the middleware will immediately halt (due
  #     # to #step) and return the failing result from the authentication
  #     # command.
  #     private def process(next_command, *args, **kwargs)
  #       current_user = step { AuthenticateUser.new.call(**kwargs) }
  #
  #       super(next_command, *args, current_user: current_user, **kwargs)
  #     end
  #   end
  #
  # @example Advanced Command Wrapping
  #   class RetryMiddleware < Cuprum::Command
  #     include Cuprum::Middleware
  #
  #     # The middleware runs the command up to three times. If a result is
  #     # passing, that result is returned immediately; otherwise, the last
  #     # failing result will be returned by the middleware.
  #     private def process(next_command, *args, **kwargs)
  #       result = nil
  #
  #       3.times do
  #         result = super
  #
  #         return result if result.success?
  #       end
  #
  #       result
  #     end
  #   end
  module Middleware
    # @!method call(next_command, *arguments, **keywords, &block)
    #   Calls the next command with the given arguments, keywords, and block.
    #
    #   Subclasses can call super to easily call the next command with the given
    #   parameters, or pass explicit parameters into super to call the next
    #   command with those parameters.
    #
    #   @param next_command [Cuprum::Command] The command to call.
    #   @param arguments [Array] The arguments to pass to the command.
    #   @param keywords [Hash] The keywords to pass to the command.
    #
    #   @yield A block to pass to the command.
    #
    #   @return [Cuprum::Result] the result of calling the command.

    # Helper method for wrapping a command with middleware.
    #
    # This method takes the given command and middleware and returns a command
    # that will call the middleware in order, followed by the given command.
    # This is done via partial application: the last item in the middleware is
    # partially applied with the given command as the middleware's next command
    # parameter. The next to last middleware is then partially applied with the
    # last middleware as the next command and so on. This ensures that the
    # middleware commands will be called in the given order, and that each
    # middleware command wraps the next, down to the given command at the root.
    #
    # @param command [Cuprum::Command] The command to wrap with middleware.
    # @param middleware [Cuprum::Middleware, Array<Cuprum::Middleware>] The
    #   middleware to wrap around the command. Will be called in the order they
    #   are given.
    #
    # @return [Cuprum::Command] the outermost middleware command, with the next
    #   command parameter partially applied.
    def self.apply(command:, middleware:)
      middleware = Array(middleware)

      return command if middleware.empty?

      middleware.reverse_each.reduce(command) do |next_command, cmd|
        cmd.curry(next_command)
      end
    end

    private

    def process(next_command, *args, **kwargs, &block)
      if kwargs.empty?
        step { next_command.call(*args, &block) }
      else
        step { next_command.call(*args, **kwargs, &block) }
      end
    end
  end
end
