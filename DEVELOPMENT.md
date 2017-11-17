# Development

- Rename Cuprum::Function to Cuprum::Command.
- Extract Cuprum::BasicCommand (excludes chaining functionality).

## Core

## Function

- Predefined functions/operations:
  - IdentityFunction
  - MapFunction
  - RetryFunction
- allow_result_argument? - defaults to false. if false, there is one argument,
  and the argument is a Result, process the value instead.

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
