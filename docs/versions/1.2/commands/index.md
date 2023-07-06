---
breadcrumbs:
  - name: Documentation
    path: '../'
---

# Commands

Commands are the core feature of Cuprum. In a nutshell, each `Cuprum::Command` is a functional object that encapsulates a business logic operation. A Command provides a consistent interface and tracking of result value and status. This minimizes boilerplate and allows for interchangeability between different implementations or strategies for managing your data and processes.

Each Command implements a `#call` method that wraps your defined business logic and returns an instance of `Cuprum::Result`. The result has a `#status` (either `:success` or `:failure`), and may have a `#value` and/or an `#error` object.

## Contents

- [Defining Commands](#defining-commands)
- [Command Results](#command-results)
  - [Success, Failure, and Errors](#success-failure-and-errors)

### See Also

- [Composing Commands](./composition)
- [Command Currying](./currying)
- [Command Factories](../factories)
- [Command Steps](./steps)
- [Handling Exceptions](./exceptions)
- [Map Commands](./map-commands)
- [Middleware](./middleware)
- [Operations](./operations)

## Defining Commands

The recommended way to define commands is to create a subclass of `Cuprum::Command` and override the `#process` method. By convention, `#process` is a private method and should not be called directly.

```ruby
class BuildBookCommand < Cuprum::Command
  private

  def process(attributes)
    Book.new(attributes)
  end
end

command = BuildPostCommand.new
result  = command.call(title: 'The Hobbit')
result.class    #=> Cuprum::Result
result.success? #=> true

book = result.value
book.class #=> Book
book.title #=> 'The Hobbit'
```

There are several takeaways from this example. First, we are defining a custom command class that inherits from `Cuprum::Command`. We are defining the `#process` method, which takes a single `attributes` parameter and returns an instance of `Book`. Then, we are creating an instance of the command, and invoking the `#call` method with an attributes hash. These attributes are passed to our `#process` implementation. Invoking `#call` returns a result, and the `#value` of the result is our new Book.

Because a command is just a Ruby object, we can also pass values to the constructor.

```ruby
class SaveBookCommand < Cuprum::Command
  def initialize(repository)
    @repository = repository
  end

  def process(book)
    if @repository.persist(book)
      success(book)
    else
      error = Cuprum::Error.new(message: 'unable to save book')

      failure(error)
    end
  end
end

books = [
  Book.new(title: 'The Fellowship of the Ring'),
  Book.new(title: 'The Two Towers'),
  Book.new(title: 'The Return of the King')
]
command = SaveBookCommand.new(books_repository)
books.each { |book| command.call(book) }
```

Here, we are defining a command that might fail - maybe the database is unavailable, or there's a constraint that is violated by the inserted attributes. If the call to `#persist` succeeds, we're returning a Result with a status of `:success` and the value set to the persisted book.
Conversely, if the call to `#persist` fails, we're returning a Result with a status of `:failure` and a custom error message. Since the `#process` method returns a Result, it is returned directly by `#call`.

Note also that we are reusing the same command three times, rather than creating a new save command for each book. Each book is persisted to the `books_repository`. This is also an example of how using commands can simplify code - notice that nothing about the `SaveBookCommand` is specific to the `Book` model. Thus, we could refactor this into a generic `SaveModelCommand`.

A command can also be defined by passing a block to `Cuprum::Command.new`.

```ruby
increment_command = Cuprum::Command.new { |int| int + 1 }

increment_command.call(2).value #=> 3
```

If the command is wrapping a method on the receiver, the syntax is even simpler:

```ruby
inspect_command = Cuprum::Command.new { |obj| obj.inspect }
inspect_command = Cuprum::Command.new(&:inspect) # Equivalent to above.
```

Commands defined using `Cuprum::Command.new` are quick to use, but more difficult to read and to reuse. Defining your own command class is recommended if a command definition takes up more than one line, or if the command will be used in more than one place.

## Command Results

Calling the `#call` method on a `Cuprum::Command` instance will always return an instance of `Cuprum::Result`. The result's `#value` property is determined by the object returned by the `#process` method (if the command is defined as a class) or the block (if the command is defined by passing a block to `Cuprum::Command.new`).

The `#value` depends on whether or not the returned object is a result or is compatible with the result interface. Specifically, any object that responds to the method `#to_cuprum_result` is considered to be a result.

If the object returned by `#process` is **not** a result, then the `#value` of the returned result is set to the object.

```ruby
command = Cuprum::Command.new { 'Greetings, programs!' }
result  = command.call
result.class #=> Cuprum::Result
result.value #=> 'Greetings, programs!'
```

If the object returned by `#process` is a result object, then the result is returned directly.

```ruby
command = Cuprum::Command.new { Cuprum::Result.new(value: 'Greetings, programs!') }
result  = command.call
result.class #=> Cuprum::Result
result.value #=> 'Greetings, programs!'
```

### Success, Failure, and Errors

Each Result has a `#status`, either `:success` or `:failure`. A Result will have a status of `:failure` when it was created with an error object. Otherwise, a Result will have a status of `:success`. Returning a failing Result from a Command indicates that something went wrong while executing the Command.

```ruby
class PublishBookCommand < Cuprum::Command
  private

  def process(book)
    if book.cover.nil?
      return Cuprum::Result.new(error: 'This book does not have a cover.')
    end

    book.published = true

    book
  end
end
```

In addition, the result object defines `#success?` and `#failure?` predicates.

```ruby
book = Book.new(title: 'The Silmarillion', cover: Cover.new)
book.published? #=> false

result = PublishBookCommand.new.call(book)
result.error    #=> nil
result.success? #=> true
result.failure? #=> false
result.value    #=> book
book.published? #=> true
```

If the result does have an error, `#success?` will return false and `#failure?` will return true.

```ruby
book = Book.new(title: 'The Silmarillion', cover: nil)
book.published? #=> false

result = PublishBookCommand.new.call(book)
result.error    #=> 'This book does not have a cover.'
result.success? #=> false
result.failure? #=> true
result.value    #=> book
book.published? #=> false
```

## See Also

- [Composing Commands](./composition)
- [Command Currying](./currying)
- [Command Factories](../factories)
- [Command Steps](./steps)
- [Handling Exceptions](./exceptions)
- [Middleware](./middleware)
- [Operations](./operations)

{% include breadcrumbs.md %}
