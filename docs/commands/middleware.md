---
breadcrumbs:
  - name: Documentation
    path: '../'
  - name: Commands
    path: '../commands'
---

# Middleware

A middleware command wraps the execution of another command, allowing the developer to compose functionality without an explicit wrapper command. Because the middleware is responsible for calling the wrapped command, it has control over when that command is called, with what parameters, and how the command result is handled.

To use middleware, start by defining a middleware command. This can either be a class that includes Cuprum::Middleware, or a command instance that extends Cuprum::Middleware. Each middleware command's #process method takes as its first argument the wrapped command. By convention, any additional arguments and any keywords or a block are passed to the wrapped command, but some middleware will override this behavior.

```ruby
class ExampleCommand < Cuprum::Command
  private def process(**options)
    return failure(options[:error]) if options[:error]

    "Options: #{options.inspect}"
  end
end

class LoggingMiddleware < Cuprum::Command
  include Cuprum::Middleware

  # The middleware injects a logging step before the wrapped command is
  # called. Notice that this middleware is generic, and can be used with
  # virtually any other command.
  private def process(next_command, *args, **kwargs)
    Logger.info("Calling command #{next_command.class}")

    super
  end
end

command    = ExampleCommand.new
middleware = LoggingMiddleware.new
result     = middleware.call(command, { id: 0 })
#=> logs "Calling command ExampleCommand"
result.value
#=> "Options: { id: 0 }"
```

When defining #process, make sure to either call super or call the wrapped command directly, unless the middleware is specifically intended not to call the wrapped command under those circumstances.

Middleware is powerful because it allows the developer to manipulate the parameters passed to a command, add handling to a result, or even intercept or override the command execution. These are some of the possible use cases for middleware:

- Injecting code before or after a command.
- Changing the parameters passed to a command.
- Adding behavior based on the command result.
- Overriding the command behavior based on the parameters.

```ruby
class AuthenticationMiddleware < Cuprum::Command
  include Cuprum::Middleware

  # The middleware finds the current user based on the given keywords. If
  # a valid user is found, the user is then passed on to the command.
  # If a user is not found, then the middleware will immediately halt (due
  # to #step) and return the failing result from the authentication
  # command.
  private def process(next_command, *args, **kwargs)
    current_user = step { AuthenticateUser.new.call(**kwargs) }

    super(next_command, *args, current_user: current_user, **kwargs)
  end
end
```

Middleware is loosely coupled, meaning that one middleware command can wrap any number of other commands. One example would be logging middleware, which could record when a command is called and with what parameters. For a more involved example, consider authorization in a web application. If individual actions are defined as commands, then a single authorization middleware class could wrap each individual action, reducing both the testing burden and the amount of code that must be maintained.

{% include breadcrumbs.md %}
