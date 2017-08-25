# Development

## Function

- Handle when block or #process returns a Result instance.
- #build_errors method
- Predefined functions/operations:
  - NullFunction
  - IdentityFunction
  - MapFunction

## Operation

- #reset! should return self

## Result

- Abort chaining with #halt!, #halted? methods.
- Force success or failure status with #success!, #failure! methods.

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
