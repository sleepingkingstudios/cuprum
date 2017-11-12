# Development

- Rename Cuprum::Function to Cuprum::Command.

## Core

- Cuprum::warn(message): |

  delegates to Cuprum::display_warning [Proc]
  defaults to ->(m) { STDERR.puts m }

## Function

- Predefined functions/operations:
  - IdentityFunction
  - MapFunction
  - RetryFunction
- allow_result_argument? - defaults to false. if false, there is one argument,
  and the argument is a Result, process the value instead.

## Operation

## Result

- #empty? - true if value.nil?, errors.nil? || errors.empty?, @status.nil?,
  @halted != true

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

- Function::instance_spy - mirrors all calls to instances

  expect(CustomFunction.function_spy).to receive(...).with(...)
