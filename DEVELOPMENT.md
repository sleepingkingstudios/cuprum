# Development

## Version 0.9.0

The "'Tis Not Too Late To Seek A Newer World" Update

## Version 0.10.0

The "One Small Step" Update

### Commands

- Implement #<<, #>> composition methods.
  - Calls commands in order passing values.
  - Return Result early on Failure (or not Success), otherwise final Result.
- Implement #step method (used in #process).
  - Called with command (block? method?) that returns a Result.
  - Raise (and catch) exception on non-success Result (test custom status?)
  - Otherwise return Result#value.

### Matcher

- Handle success(), failure(), failure(SomeError) cases.
  - Custom matcher to handle additional cases - halted, pending, etc?

### RSpec

- be_callable matcher - delegates to respond_to(), but check arguments of
  private #process method
- be_a_result matcher
  - smarter detection of RSpec matchers when generating text
    - do not just check for #description method!
  - be_a_passing_result macro should default to with_error(nil)
    - provides addl context on unexpected failure

## Version 1.0.0

'The "Look On My Works, Ye Mighty, and Despair" Update'

- Integration specs.
- Configuration option to raise, warn, ignore discarded results.
- Code cleanup: Hash syntax, remove end comments, remove file headers

### Commands

- Command#to_proc
- :clear_errors => true option on #chain

### Commands - Built In

- MapCommand - wraps a command (or proc) and returns Result with value, errors
  as array
- RetryCommand

### Documentation

Chaining Case Study: |

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

## Future Versions

### Commands

- command currying

#### Cuprum::DSL

- ::process - shortcut for defining #process
- ::rescue - `rescue StandardError do ... end`, rescues matched errors in #process
- chaining methods:
  - ::chain (::success, ::failure):
    on #initialize, chains the given command. Can be given a command class
    (if ::new takes no arguments) or a block that returns a command.
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
