---
breadcrumbs:
  - name: Documentation
    path: '../../'
  - name: Versions
    path: '../'
  - name: '1.0'
    path: './'
---

# Matchers

A Matcher provides a simple DSL for defining behavior based on a Cuprum result object.

## Contents

- [Defining Matchers](#defining-matchers)
- [Matching Values And Errors](#matching-values-and-errors)
- [Using Matcher Classes](#using-matcher-classes)
- [Match Contexts](#match-contexts)
- [Matcher Lists](#matcher-lists)

## Defining Matchers

```ruby
matcher = Cuprum::Matcher.new do
  match(:failure) { 'Something went wrong' }

  match(:success) { 'Ok' }
end

matcher.call(Cuprum::Result.new(status: :failure))
#=> 'Something went wrong'

matcher.call(Cuprum::Result.new(status: :success))
#=> 'Ok'
```

First, the matcher defines possible matches using the `.match` method. This can either be called on a subclass of `Cuprum::Matcher` or by passing a block to the constructor, as above. Each match clause must have the matching status, and a block that is executed when a result matches that clause. The clause can also filter by the result value or error (see Matching Values And Errors, below).

Once the matcher has found a matching clause, it then calls the block in the clause definition. If the block accepts an argument, the result is passed to the block; otherwise, the block is called with no arguments. This allows the match clause to use the error or value of the result.

```ruby
matcher = Cuprum::Matcher.new do
  match(:failure) { |result| result.error.message }
end

error = Cuprum::Error.new(message: 'An error has occurred.')
matcher.call(Cuprum::Result.new(error: error))
#=> 'An error has occurred.'
```

If the result does not match any of the clauses, a `Cuprum::Matching::NoMatchError` is raised.

```ruby
matcher = Cuprum::Matcher.new do
  match(:success) { :ok }
end

matcher.call(Cuprum::Result.new(status: :failure))
#=> raises Cuprum::Matching::NoMatchError
```

## Matching Values And Errors

In addition to a status, match clauses can specify the type of the value or error of a matching result. The error or value must be a Class or Module, and the clause will then match only results whose error or value is an instance of the specified Class or Module (or a subclass of the Class).

```ruby
class MagicSmokeError < Cuprum::Error; end

matcher = Cuprum::Matcher.new do
  match(:failure) { 'Something went wrong.' }

  match(:failure, error: Cuprum::Error) do |result|
    "ERROR: #{result.error.message}"
  end

  match(:failure, error: MagicSmokeError) do
    "PANIC: #{result.error.message}"
  end
end

matcher.call(Cuprum::Result.new(status: :failure))
#=> 'Something went wrong.'

error = Cuprum::Error.new(message: 'An error has occurred.')
matcher.call(Cuprum::Result.new(error: error)
#=> 'ERROR: An error has occurred.'

error = MagicSmokeError.new(message: 'The magic smoke is escaping.')
matcher.call(Cuprum::Result.new(error: error))
#=> 'PANIC: The magic smoke is escaping.'
```

The matcher will always apply the most specific match clause. In the example above, the result with a `MagicSmokeError` matches all three clauses, but only the final clause is executed.

You can also specify the value of a matching result:

```ruby
matcher = Cuprum::Matcher.new do
  match(:success, value: String) { 'a String' }

  match(:success, value: Symbol) { 'a Symbol' }
end

matcher.call(Cuprum::Result.new(value: 'Greetings, programs!'))
#=> 'a String'

matcher.call(Cuprum::Result.new(value: :greetings_starfighter))
#=> 'a Symbol'
```

## Using Matcher Classes

Matcher classes allow you to define custom behavior that can be called as part of the defined match clauses.

```ruby
class LogMatcher < Cuprum::Matcher
  match(:failure) { |result| log(:error, result.error.message) }

  match(:success) { log(:info, 'Ok') }

  def log(level, message)
    puts "#{level.upcase}: #{message}"
  end
end

matcher = LogMatcher.new
matcher.call(Cuprum::Result.new(status: :success))
#=> prints "INFO: Ok" to STDOUT
```

Match clauses are also inherited by matcher subclasses. Inherited clauses are sorted the same as clauses defined on the matcher directly - the most specific clause is matched first, followed by less specific clauses and finally the generic clause (if any) for that result status.

```ruby
class CustomLogMatcher < Cuprum::Matcher
  match(:failure, error: ReallyBadError) do |result|
    log(:fatal, result.error.message)
  end
end

matcher = CustomLogMatcher.new
result  = Cuprum::Result.new(error: Cuprum::Error.new('Something went wrong.'))
matcher.call(result)
#=> prints "ERROR: Something went wrong." to STDOUT

result  = Cuprum::Result.new(error: ReallyBadError.new('Computer on fire.'))
matcher.call(result)
#=> prints "FATAL: Computer on fire." to STDOUT
```

## Match Contexts

Match contexts provide an alternative to defining custom matcher classes - instead of defining custom behavior in the matcher itself, the match clauses can be executed in the context of another object.

```ruby
class Inflector
  def capitalize(message)
    message.split(' ').map(&:capitalize).join(' ')
  end
end

matcher = Cuprum::Matcher.new(inflector) do
  match(:success) { |result| capitalize(result.value) }
end
matcher.call(Cuprum::Result.new(value: 'greetings starfighter'))
#=> 'Greetings Starfighter'
```

For example, a controller in a web framework might need to define behavior for handling different success and error cases for business logic that is defined as Commands. The controller itself defines methods such as `#render` and `#redirect` - by creating a matcher using the controller as the match context, the matcher can call upon those methods to generate a response.

You can also call an existing matcher with a new context. The `#with_context` method returns a copy of the matcher with the given object set as the match context.

```ruby
matcher = Cuprum::Matcher.new do
  match(:success) { |result| capitalize(result.value) }
end
matcher
  .with_context(inflector)
  .call(Cuprum::Result.new(value: 'greetings starfighter'))
#=> 'Greetings Starfighter'
```

## Matcher Lists

Matcher lists handle matching a result against an ordered group of matchers.

When given a result, a matcher list will check for the most specific matching clause in each of the matchers. A clause matching both the value and error will match first, followed by a clause matching only the result value or error, and finally a clause matching only the result status will match.

If none of the matchers have a clause that matches the result, a `Cuprum::Matching::NoMatchError` will be raised.

```ruby
generic_matcher = Cuprum::Matcher.new do
  match(:failure) { 'generic failure' }
  #
  match(:failure, error: CustomError) { 'custom failure' }
end
specific_matcher = Cuprum::Matcher.new do
  match(:failure, error: Cuprum::Error) { 'specific failure' }
end
matcher_list = Cuprum::MatcherList.new(
  [
    specific_matcher,
    generic_matcher
  ]
)

generic_matcher = Cuprum::Matcher.new do
  match(:failure) { 'generic failure' }

  match(:failure, error: CustomError) { 'custom failure' }
end
specific_matcher = Cuprum::Matcher.new do
  match(:failure, error: Cuprum::Error) { 'specific failure' }
end
matcher_list = Cuprum::MatcherList.new(
  [
    specific_matcher,
    generic_matcher
  ]
)

# A failure without an error does not match the first matcher, so the
# matcher list continues on to the next matcher in the list.
result = Cuprum::Result.new(status: :failure)
matcher_list.call(result)
#=> 'generic failure'

# A failure with an error matches the first matcher.
error  = Cuprum::Error.new(message: 'Something went wrong.')
result = Cuprum::Result.new(error: error)
matcher_list.call(result)
#=> 'specific failure'

# A failure with an error subclass still matches the first matcher, even
# though the second matcher has a more exact match.
error  = CustomError.new(message: 'The magic smoke is escaping.')
result = Cuprum::Result.new(error: error)
matcher_list.call(result)
#=> 'specific failure'
```

One use case for matcher lists would be in defining hierarchies of classes or objects that have matching functionality. For example, a generic controller class might define default success and failure behavior, an included mixin might provide handling for a particular scope of errors, and a specific controller might override the default behavior for a given action. Using a matcher list allows each class or module to define its own behavior as independent matchers, which the matcher list then composes together.

{% include breadcrumbs.md %}
