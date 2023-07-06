---
breadcrumbs:
  - name: Documentation
    path: '../../../'
  - name: Versions
    path: '../../'
  - name: '1.2'
    path: '../'
  - name: Commands
    path: '../commands'
---

# Map Commands

A `Cuprum::MapCommand` calls the command implementation with each item in the given enumerable object.

A regular Command is called with a set of parameters, calls the command implementation once with those parameters, and returns the Result. In contrast, a MapCommand is called with an Enumerable object, such as an `Array`, a `Hash`, or an `Enumerator` (e.g. by calling `#each` without a block). The MapCommand implementation is then called with each item in the Enumerable - for example, if called with an Array with three items, the MapCommand implementation would be called three times, once with each item. Finally, the Results returned by calling the implementation with each item are aggregated together into a `Cuprum::ResultList`. A ResultList behaves like a Result, and provides the standard methods (such as `#status`, `#error`, and `#value`), but also includes a reference to the #results used to create the ResultList, and their respective `#error`s and `#value`s as Arrays.

Like a standard Command, a MapCommand can be defined either by passing a block to the constructor, or by defining a subclass of MapCommand and implementing the #process method. If the given block or the #process method accepts more than one argument, the enumerable item is destructured using the splat operator (\*); this enables using a MapCommand to map over the keys and values of a Hash. This is the same behavior seen when passing a block with multiple arguments to a native `#each` method.

## Contents

- [Defining Map Commands](#defining-map-commands)
- [Calling Map Commands](#calling-map-commands)
  - [Success, Failure, and Errors](#success-failure-and-errors)
  - [Partial Success](#partial-success)

## Defining Map Commands

As with a regular command, a map command can be defined by passing a block to `.new`.

```ruby
capitalize_command = Cuprum::MapCommand.new do |str|
  if str.nil? || str.empty?
    next failure(Cuprum::Error.new(message: "can't be blank"))
  end

  str.capitalize
end
```

If you have an existing command, you can turn it into a map command by passing it to `MapCommand.new`. This leverages the `Command#to_proc` method.

```ruby
titleize_one  =
  Cuprum::Command.new { |str| str.split(' ').map(&:capitalize).join(' ') }
titleize_list = Cuprum::MapCommand.new(&titleize_one)
```

You can also define a custom subclass of MapCommand.

```ruby
class TitleizeCommand < Cuprum::MapCommand
  private def process(str)
    if str.nil? || str.empty?
      return failure(Cuprum::Error.new(message: "can't be blank"))
    end

    str.split(' ').map(&:capitalize).join(' ')
  end
end
```

## Calling Map Commands

When a map command is called, it returns an instance of [Cuprum::ResultList](../results#result-lists). A result list is a subclass of `Cuprum::Result` that aggregates multiple result values together. It defines the same interface as a standard result - the `#status`, `#value`, and `#error` methods - but also provides access to the individual result for each item in the enumerable object.

```ruby
greetings = ['hello world', 'greetings programs', 'greetings starfighter']
result    = titleize_command.call(greetings)
result.class
#=> Cuprum::ResultList
```

A ResultList implements the standard Result methods:

```ruby
result.status
#=> :success
result.value
#=> ['Hello World', 'Greetings Programs', 'Greetings Starfighter']
result.error
#=> nil
```

In addition, you can view the individual results, or the respective statuses, values, or errors.

```ruby
result.statuses
#=> [:success, :success, :success]
result.values
#=> ['Hello World', 'Greetings Programs', 'Greetings Starfighter']
result.errors
#=> [nil, nil, nil]
result.results
#=> [#<Cuprum::Result>, #<Cuprum::Result>, #<Cuprum::Result>]
```

You can also define and call a map command with a Hash.

```ruby
join_command = Cuprum::MapCommand.new do |key, value|
  "#{key}: #{value}"
end
result       = join_command.call({ ichi: 1, ni: 2, san: 3 })
result.value
#=> ["ichi: 1", "ni: 2", "san: 3"]
```

### Success, Failure, and Errors

The success or failure of a returned ResultList depends on the status of each individual Result.

An **empty** ResultList (with no Results) will have a status of `:success`. For example, passing an empty Array into a MapCommand will return an empty, successful ResultList.

```ruby
results = capitalize_command.call([])
results.class
#=> Cuprum::ResultList
results.success?
#=> true
results.statuses
#=> []
results.value
#=> []
results.error
```

A non-empty ResultList will have a status of `:success` if and only if **all** of the Results are passing.

```ruby
strings = %w[greetings programs]
results = capitalize_command.call(strings)
results.success?
#=> true
results.statuses
#=> [:success, :success, :success]
results.value
#=> ['Greetings', 'Programs']
```

A non-empty ResultList will have a status of `:failure` if **any** of the Results are failing.

```ruby
strings = ['greetings', nil, 'programs']
results = capitalize_command.call(strings)
results.success?
#=> false
results.statuses
#=> [:success, :failure, :success]
results.value
#=> ['Greetings', nil, 'Programs']
```

If there are any failing results, the corresponding errors will be aggregated together into a `Cuprum::Errors::MultipleErrors` error.

```ruby
strings = ['greetings', nil, 'programs']
results = capitalize_command.call(strings)
results.error.class
#=> Cuprum::Errors::MultipleErrors
results.error.errors
#=> [nil, #<Cuprum::Error>, nil]
results.error.errors.map { |err| err&.message }
#=> [nil, "can't be blank", nil]
```

### Partial Success

A map command can also be configured to pass if there are **any** passing results (or an empty input) by setting the `:allow_partial` flag to true.

```ruby
downcase_command = Cuprum::MapCommand.new(allow_partial: true) do |str|
  if str.nil? || str.empty?
    next failure(Cuprum::Error.new(message: "can't be blank"))
  end

  str.downcase
end

strings = ['greetings', nil, 'programs']
results = downcase_command.call(strings)
results.success?
#=> true
results.statuses
#=> [:success, :failure, :success]
```

{% include breadcrumbs.md %}
