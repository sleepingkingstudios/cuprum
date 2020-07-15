# Development

## Version 0.10.0

The "One Small Step" Update

### Commands

- Deprecate #chain and its related methods
- In Cuprum::Command, wrap #process in #steps (see below)

#### Middleware

- Implement Cuprum::Middleware
  - #process takes next command, \*args, \*\*kwargs
    - calls next command with \*args, \*\*kwargs
  - .apply takes middleware: array, root: command
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

#### Steps

- Implement #step method
  - Called with result, e.g. `step my_operation.call(some_params)`
  - Called with block, e.g. `step { my_method(my_args) }`
    - Block form wraps the value in a result
  - If the result is not success, throw :cuprum_failed_step and the result.
  - Otherwise return Result#value.
- Implement #steps method
  - Called with block, e.g. `steps { step something }`
  - Catches :cuprum_failed_step and returns the thrown result.
  - Otherwise wraps the value in a result.

### Documentation

Steps Case Study: |

  CMS application - creating a new post.
  Directory has many Posts
  Post has a Content
  Content has many ContentVersions
  Post has many Tags

  Find Directory
  Create Post
  Create Content
  Create ContentVersion
  Tags.each { FindOrCreate Tag }

### Matcher

- Handle success(), failure(), failure(SomeError) cases.
  - Custom matcher to handle additional cases - halted, pending, etc?

### RSpec

- be_callable matcher - delegates to respond_to(), but check arguments of
  private #process method
- call_command_step matcher
- (optionally) alias be_a_result family as have_result for operations

## Version 1.0.0

'The "Look On My Works, Ye Mighty, and Despair" Update'

- Integration specs.
- Configuration option to raise, warn, ignore discarded results.
- Code cleanup: Hash syntax, remove end comments, remove file headers

### Commands

- Command#to_proc
- Remove #chain and its related methods

### Commands - Built In

- MapCommand - wraps a command (or proc) and returns Result with value, errors
  as array
- RetryCommand - takes command, retry count
  - optional only:, except: - restrict what errors are retried

## Future Versions

### Commands

- Implement #<<, #>> composition methods.
  - Calls commands in order passing values.
  - Return Result early on Failure (or not Success), otherwise final Result.

#### Cuprum::DSL

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

### Steps::Strict

- #step raises exception unless block or method returns a result
