# Development

## Function

- #build_errors method
- Predefined functions/operations:
  - NullFunction
  - IdentityFunction
  - MapFunction
  - RetryFunction
- Handle calling #call or #process while calling a Function.

## Operation

- #reset! should return self

## Result

- Abort chaining with #halt!, #halted? methods, unless :on => :always.
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
