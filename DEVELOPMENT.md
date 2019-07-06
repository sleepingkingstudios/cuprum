# Development

## Version 0.9.0

The "'Tis Not Too Late To Seek A Newer World" Update

- Remove autoload.

### Commands

- #process DOES NOT have reference to a current Result.
- #process either returns a Result or a value (converted to successful Result).
- define helper methods:
  - #success(value)  => returns passing Result with value # Optional
  - #failure(errors) => returns failing Result with errors

### Results

- Results are immutable
  - Remove methods #errors=, #value=, #failure!, #success!, #update.
- Alias #errors as #error.

#### Custom Statuses

- Add :status keyword to initializer
  - Defaults to :success or :failure
  - Private #statuses method? Override to allow custom status.
- Example custom statuses: #halted, #pending, etc?

## Version 0.10.0

The "One Small Step" Update

### Commands

- Implement #<<, #>> composition methods.
  - Calls commands in order passing values.
  - Return Result early on Failure, otherwise final Result.
- Implement #step method (used in #process).
  - Called with command (block? method?) that returns a Result.
  - Raise (and catch) exception on non-success Result (test custom status?)
  - Otherwise return Result#value.

### Matcher

- Handle success(), failure(), failure(SomeError) cases.
  - Custom matcher to handle additional cases - halted, pending, etc?

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

#### Hooks
