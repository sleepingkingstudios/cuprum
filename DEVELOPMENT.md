# Development

## Version 0.7.0

- Update documentation.
- Add additional Ruby versions to test matrix.

## Version 1.0.0+

'The "Look On My Works, Ye Mighty, and Despair" Update'

- Integration specs.

### Commands

- Protected Chaining Methods:
  - #chain!, #success!, #failure!, #tap_chain!, #yield_result!
  - adds chained command to current command instead of a clone.
- Command#to_proc

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

- :before, :around, :after hooks

### Commands - Built In

- MapCommand - wraps a command (or proc) and returns Result with value, errors
  as array
- RetryCommand

### CommandFactory

- builder/aggregator for command objects, esp. with shared
  initializers/parameters, e.g. actions for a resource
- Syntax: |

  actions = ResourceCommandFactory.new(Book)
  command = actions::Build.new        #=> returns a book builder command
  result  = command.call(attributes)  #=> returns a result with value => a Book
  # OR
  result  = actions.build(attributes) #=> returns a result with value => a Book
  book    = result.value

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
