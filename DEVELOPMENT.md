# Development

- Update documentation.

## Core

- Integration specs.
- Refactor Cuprum::BasicCommand to Cuprum::Processing module.
- Extract helpers #errors, #failure!, #success!, #halt! to
  Cuprum::ResultHelpers module.
- Refactor Cuprum::Command to module.

## Command

- Chaining Methods:
  - #chain:
    - with a command, sets the command's #result to the last result and calls
      #process with the last result's #value; returns result of calling chained
      command.
    - with a block creates anonymous command, then see above
    - if the command does not accept any arguments (or keywords if #value is a
      Hash), does not pass #value. Requires #arity, #apply_chained?
    - one keyword (on), values nil (default), :success, :failure, :always
  - #success - as chain(:on => :success)
  - #failure - as chain(:on => :failure)
  - #tap_result:
    - block form only, block is yielded and returns the last result
    - same argument as #chain
  - #yield_result:
    - block form only, block is yielded the last result, returns the return
      value of the block (wrapped in a result if needed)
    - same argument as #chain
- Protected Chaining Methods:
  - #chain!, #success!, #failure!, #tap_chain!, #yield_result!
  - adds chained command to current command instead of a clone.
- Command#to_proc

### Built In

- MapCommand - wraps a command (or proc) and returns Result with value, errors
  as array
- RetryCommand

### DSL

- class-level methods
  - ::chain (::success, ::failure):
    on #initialize, chains the given command. Can be given a command class
    (if ::new takes no arguments) or a block that returns a command.
  - ::process - shortcut for defining #process
  - ::rescue - `rescue StandardError do ... end`, rescues matched errors in #process

### Hooks

- :before, :around, :after hooks

## Operation

## Result

## Documentation

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

## Testing
