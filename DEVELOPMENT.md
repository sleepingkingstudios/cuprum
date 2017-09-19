# Development

## Function

- Predefined functions/operations:
  - IdentityFunction
  - MapFunction
  - RetryFunction

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

- assert_chained_function
- have_chained_function() matcher
