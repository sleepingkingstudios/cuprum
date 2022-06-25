---
breadcrumbs:
  - name: Documentation
    path: './'
---

# Results

```ruby
require 'cuprum'
```

A `Cuprum::Result` is a data object that encapsulates the result of calling a Cuprum command. Each result has a `#value`, an `#error` object (defaults to `nil`), and a `#status` (either `:success` or `:failure`, and accessible via the `#success?` and `#failure?` predicates).

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

{% include breadcrumbs.md %}
