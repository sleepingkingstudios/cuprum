---
breadcrumbs:
  - name: Documentation
    path: './'
---

# Results

A `Cuprum::Result` is a data object that encapsulates the result of calling a Cuprum command.

## Contents

- [Value, Error, and Status](#value-error-and-status)
- [Result Lists](#result-lists)
  - [Success and Failure](#result-list-success-and-failure)
    - [Partial Success](#result-list-partial-success)
  - [Values](#result-list-values)
  - [Errors](#result-list-errors)

## Value, Error, and Status

Each result has a `#value`, an `#error` object (defaults to `nil`), and a `#status`. By default, the status will be either `:success` or `:failure`, and accessible via the `#success?` and `#failure?` predicates.

```ruby
result = Cuprum::Result.new

result.value    #=> nil
result.error    #=> nil
result.status   #=> :success
result.success? #=> true
result.failure? #=> true
```

Creating a result with a value stores the value.

```ruby
value  = 'A result value'.freeze
result = Cuprum::Result.new(value: value)

result.value    #=> 'A result value'
result.error    #=> nil
result.status   #=> :success
result.success? #=> true
result.failure? #=> false
```

Creating a Result with an error stores the error and sets the status to `:failure`.

```ruby
error  = Cuprum::Error.new(message: "I'm sorry, something went wrong.")
result = Cuprum::Result.new(error: error)
result.value    #=> nil
result.error    #=> Error with message "I'm sorry, something went wrong."
result.status   #=> :failure
result.success? #=> false
result.failure? #=> true
```

Although using a `Cuprum::Error` instance as the `:error` is recommended, it is not required. You can use a custom error object, or just a string message.

```ruby
result = Cuprum::Result.new(error: "I'm sorry, something went wrong.")
result.value    #=> nil
result.error    #=> "I'm sorry, something went wrong."
result.status   #=> :failure
result.success? #=> false
result.failure? #=> true
```

Finally, the status can be overridden via the `:status` keyword.

```ruby
result = Cuprum::Result.new(status: :failure)
result.error    #=> nil
result.status   #=> :failure
result.success? #=> false
result.failure? #=> true

error  = Cuprum::Error.new(message: "I'm sorry, something went wrong.")
result = Cuprum::Result.new(error: error, status: :success)
result.error    #=> Error with message "I'm sorry, something went wrong."
result.status   #=> :success
result.success? #=> true
result.failure? #=> false
```

## Result Lists

A `Cuprum::ResultList` is a special type of Result that aggregates together a number of other results.

```ruby
result_list = Cuprum::ResultList.new(
  Cuprum::Result.new(status: :success, value: :ok),
  Cuprum::Result.new(status: :failure),
  Cuprum::Result.new(error: 'Something went wrong')
)
result_list.results
#=> [#<Cuprum::Result>, #<Cuprum::Result>, #<Cuprum::Result>]
```

Each ResultList defines the same interface as a standard Result: the `#value`, `#error`, and `#status` methods and the `#success?` and `#failure?` predicates.

```ruby
result_list.value
#=> [:ok, nil, nil]
result_list.error
#=> #<Cuprum::Errors::MultipleErrors>
result_list.error.errors
#=> [nil, nil, 'Something went wrong']
result_list.status
#=> :failure
result_list.success?
#=> false
result_list.failure?
#=> true
```

### Success And Failure
{: #result-list-success-and-failure }

The status of a result list depends on the statuses of its constituent results.

An **empty** ResultList (with no Results) will have a status of `:success`.

```ruby
result_list = Cuprum::ResultList.new
result_list.status
#=> :success
```

A non-empty ResultList will have a status of `:success` if and only if **all** of the Results are passing.

```ruby
result_list = Cuprum::ResultList.new(
  Cuprum::Result.new(status: :success),
  Cuprum::Result.new(status: :success),
  Cuprum::Result.new(status: :success)
)
result_list.status
#=> :success
```

A non-empty ResultList will have a status of `:failure` if **any** of the Results are failing.

```ruby
result_list = Cuprum::ResultList.new(
  Cuprum::Result.new(status: :success),
  Cuprum::Result.new(status: :failure),
  Cuprum::Result.new(status: :success)
)
result_list.status
#=> :failure
```

#### Partial Success
{: #result-list-partial-success }

A result list can also be configured to pass if there are **any** passing results (or an empty input) by setting the `:allow_partial` flag to true.

```ruby
result_list = Cuprum::ResultList.new(
  Cuprum::Result.new(status: :success),
  Cuprum::Result.new(status: :failure),
  Cuprum::Result.new(status: :success),
  allow_partial: true
)
result_list.status
#=> :success
```

### Values
{: #result-list-values }

By default, the `#value` of a ResultList is equal to the mapped values of each constituent result. These values can also be accessed directly by calling the `#values` method.

```ruby
result_list = Cuprum::ResultList.new(
  Cuprum::Result.new(value: 'Hello world'),
  Cuprum::Result.new(value: 'Greetings, programs!'),
  Cuprum::Result.new(status: :success)
)
result_list.value
#=> ['Hello world', 'Greetings, programs!', nil]
result_list.values
#=> ['Hello world', 'Greetings, programs!', nil]
```

A ResultList can also be initialized with a custom value.

```ruby
result_list = Cuprum::ResultList.new(
  Cuprum::Result.new(value: 'Hello world'),
  Cuprum::Result.new(value: 'Greetings, programs!'),
  Cuprum::Result.new(status: :success),
  value: { ok: true }
)
result_list.value
#=> { ok: true }
result_list.values
#=> ['Hello world', 'Greetings, programs!', nil]
```

The individual values can also be accessed via the `#values` property of the result list.

### Errors
{: #result-list-errors }

If the result list is empty, or if none of the results in the result list have an error, then the ResultList's own `#error` property will be `nil`.

```ruby
result_list = Cuprum::ResultList.new(
  Cuprum::Result.new(status: :success),
  Cuprum::Result.new(status: :failure),
  Cuprum::Result.new(status: :failure)
)
result_list.error
#=> nil
result_list.errors
#=> [nil, nil, nil]
```

If at least one of the results has an error object, the result errors are aggregated together into a `Cuprum::Errors::MultipleErrors` object.

```ruby
result_list = Cuprum::ResultList.new(
  Cuprum::Result.new(status: :success),
  Cuprum::Result.new(
    status: :failure,
    error: Cuprum::Error.new(message: 'Something went wrong')),
  Cuprum::Result.new(status: :failure)
)
result_list.error.class
#=> Cuprum::Errors::MultipleErrors
result_list.error.message
#=> 'the command encountered one or more errors'
result_list.error.errors
#=> [nil, #<Cuprum::Error>, nil]
result_list.errors
#=> [nil, #<Cuprum::Error>, nil]
```

The individual errors can also be accessed via the `#errors` property of the result list.

{% include breadcrumbs.md %}
