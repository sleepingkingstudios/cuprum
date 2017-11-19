# Development

- Update documentation.
  - Similar gems:
    interactor: https://github.com/collectiveidea/interactor
    trailblazer-operation: http://trailblazer.to
    waterfall: https://github.com/apneadiving/waterfall

## Core

## Command

- Predefined commands/operations:
  - RetryCommand
- allow_result_argument? - defaults to false. if false, there is one argument,
  and the argument is a Result, process the value instead.
- #chain!, #else!, #then! - adds chained function to current command instead of
  a clone.

### DSL

- class-level methods
  - ::chain (::else, ::then):
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
