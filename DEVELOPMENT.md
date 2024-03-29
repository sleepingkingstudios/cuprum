# Development

## Future Versions

Add `.rbs` files

### Commands

- Implement #<<, #>> composition methods.
  - Calls commands in order passing values.
  - Return Result early on Failure (or not Success), otherwise final Result.

#### DSL

- ::process - shortcut for defining #process
- ::rescue - `rescue StandardError do ... end`, rescues matched errors in #process
- constructor methods:
  - Programmatically generate a constructor method. Raises an error if
    #initialize is defined. Automatically sets instance variables on initialize,
    and defines reader methods.
  - ::arguments - sets all positional arguments in the constructor. Takes 0 or
    more String or Symbol arguments representing required arguments. Takes an
    optional hash with String/Symbol keys and arbitrary values, representing
    optional arguments and their default values.
  - ::keywords - sets keyword arguments; same arguments as ::arguments.

#### Dependency Injection

- shorthand for referencing a sequence of operations

### Commands - Built In

- MapCommand - wraps a command (or proc) and returns Result with value, errors
  as array
- RetryCommand - takes command, retry count
  - optional only:, except: - restrict what errors are retried

### Middleware

- Implement Command.subclass
  - Curries constructor arguments
- Implement Cuprum::AppliedMiddleware < Cuprum::Command
  - has readers #root (Class), #middleware (Array<Class>)
  - #initialize
    - initializes root command (passing constructor parameters)
    - initializes each middleware command
      - if Class defining .instance, call .instance
      - if Class, call .new
      - if Proc, call #call with constructor parameters
    - calls Middleware.apply and caches as private #applied
  - #call
    - delegates to #applied

### RSpec

- call_command_step matcher
- (optionally) alias be_a_result family as have_result for operations

### Steps::Strict

- #step raises exception unless block or method returns a result
