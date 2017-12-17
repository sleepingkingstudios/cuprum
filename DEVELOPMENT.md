# Development

- Update documentation.

## Core

- Integration specs.
- Refactor Cuprum::BasicCommand to Cuprum::Processing module.
- Extract helpers #errors, #failure!, #success!, #halt! to
  Cuprum::ResultHelpers module.
- Refactor Cuprum::Command to module.
- Extract #result_not_empty_warning from BasicCommand.

## Command

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
