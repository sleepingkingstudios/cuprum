## Cuprum

An opinionated implementation of the Command pattern for Ruby applications. Cuprum wraps your business logic in a consistent, object-oriented interface and features status and error management, composability and control flow management.

It defines the following concepts:

- [Commands](#Commands) - A function-like object that responds to `#call` and returns a `Result`.
- [Operations](#Operations) - A stateful `Command` that wraps and delegates to its most recent `Result`.
- [Results](#Results) - An immutable data object with a status (either `:success` or `:failure`), and either a `#value` or an `#error` object.
- [Errors](#Errors) - Encapsulates a failure state of a command.

## About

[comment]: # "Status Badges will go here."

Traditional frameworks such as Rails focus on the objects of your application - the "nouns" such as User, Post, or Item. Using Cuprum or a similar library allows you the developer to make your business logic - the "verbs" such as Create User, Update Post or Ship Item - a first-class citizen of your project. This provides several advantages:

- **Consistency:** Use the same Commands to underlie controller actions, worker processes and test factories.
- **Encapsulation:** Each Command is defined and run in isolation, and dependencies must be explicitly provided to the command when it is initialized or run. This makes it easier to reason about the command's behavior and keep it insulated from changes elsewhere in the code.
- **Testability:** Because the logic is extracted from unnecessary context, testing its behavior is much cleaner and easier.
- **Composability:** Complex logic such as "find the object with this ID, update it with these attributes, and log the transaction to the reporting service" can be extracted into a series of simple Commands and composed together. The [step](#label-Command+Steps) feature allows for complex control flows.
- **Reusability:** Logic common to multiple data models or instances in your code, such as "persist an object to the database" or "find all records with a given user and created in a date range" can be refactored into parameterized commands.

### Alternatives

If you want to extract your logic but Cuprum is not the right solution for you, there are a number of alternatives, including
[ActiveInteraction](https://github.com/AaronLasseigne/active_interaction),
[Dry::Monads](https://dry-rb.org/gems/dry-monads/),
[Interactor](https://github.com/collectiveidea/interactor),
[Trailblazer](http://trailblazer.to/) Operations,
and [Waterfall](https://github.com/apneadiving/waterfall).

### Compatibility

Cuprum is tested against Ruby (MRI) 2.3 through 2.5.

### Documentation

Method and class documentation is available courtesy of [RubyDoc](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master).

Documentation is generated using [YARD](https://yardoc.org/), and can be generated locally using the `yard` gem.

### License

Copyright (c) 2019 Rob Smith

Cuprum is released under the [MIT License](https://opensource.org/licenses/MIT).

### Contribute

The canonical repository for this gem is located at https://github.com/sleepingkingstudios/cuprum.

To report a bug or submit a feature request, please use the [Issue Tracker](https://github.com/sleepingkingstudios/cuprum/issues).

To contribute code, please fork the repository, make the desired updates, and then provide a [Pull Request](https://github.com/sleepingkingstudios/cuprum/pulls). Pull requests must include appropriate tests for consideration, and all code must be properly formatted.

### Credits

Hi, I'm Rob Smith, a Ruby Engineer and the developer of this library. I use these tools every day, but they're not just written for me. If you find this project helpful in your own work, or if you have any questions, suggestions or critiques, please feel free to get in touch! I can be reached [on GitHub](https://github.com/sleepingkingstudios/cuprum) or [via email](mailto:merlin@sleepingkingstudios.com). I look forward to hearing from you!

## Concepts

<a id="Commands"></a>

### Commands

    require 'cuprum'

Commands are the core feature of Cuprum. In a nutshell, each `Cuprum::Command` is a functional object that encapsulates a business logic operation. A Command provides a consistent interface and tracking of result value and status. This minimizes boilerplate and allows for interchangeability between different implementations or strategies for managing your data and processes.

Each Command implements a `#call` method that wraps your defined business logic and returns an instance of `Cuprum::Result`. The result has a status (either `:success` or `:failure`), and may have a `#value` and/or an `#error` object. For more details about Cuprum::Result, [see below](#label-Results).

[Class Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum%2FCommand)

#### Defining Commands

The recommended way to define commands is to create a subclass of `Cuprum::Command` and override the `#process` method.

```ruby
class BuildBookCommand < Cuprum::Command
  def process attributes
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
  def initialize repository
    @repository = repository
  end

  def process book
    if @repository.persist(book)
      success(book)
    else
      failure('unable to save book')
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

A command can also be defined by passing block to `Cuprum::Command.new`.

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

#### Result Values

Calling the `#call` method on a `Cuprum::Command` instance will always return an instance of `Cuprum::Result`. The result's `#value` property is determined by the object returned by the `#process` method (if the command is defined as a class) or the block (if the command is defined by passing a block to `Cuprum::Command.new`).

The `#value` depends on whether or not the returned object is a result or is compatible with the result interface. Specifically, any object that responds to the method `#to_cuprum_result` is considered to be a result.

If the object returned by `#process` is **not** a result, then the `#value` of the returned result is set to the object.

```ruby
command = Cuprum::Command.new { 'Greetings, programs!' }
result  = command.call
result.class #=> Cuprum::Result
result.value #=> 'Greetings, programs!'
```

If the object returned by `#process` is a result object, then result is returned directly.

```ruby
command = Cuprum::Command.new { Cuprum::Result.new(value: 'Greetings, programs!') }
result  = command.call
result.class #=> Cuprum::Result
result.value #=> 'Greetings, programs!'
```

#### Success, Failure, and Errors

Each Result has a status, either `:success` or `:failure`. A Result will have a status of `:failure` when it was created with an error object. Otherwise, a Result will have a status of `:success`. Returning a failing Result from a Command indicates that something went wrong while executing the Command.

```ruby
class PublishBookCommand < Cuprum::Command
  private

  def process book
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

#### Command Currying

Cuprum::Command defines the `#curry` method, which allows for partial application of command objects. Partial application (more commonly referred to, if imprecisely, as currying) refers to fixing some number of arguments to a function, resulting in a function with a smaller number of arguments.

In Cuprum's case, a curried (partially applied) command takes an original command and pre-defines some of its arguments. When the curried command is called, the predefined arguments and/or keywords will be combined with the arguments passed to #call.

##### Currying Arguments

We start by defining the base command. In this case, our base command takes two string arguments - a greeting and a person to be greeted.

```ruby
say_command = Cuprum::Command.new do |greeting, person|
  "#{greeting}, #{person}!"
end
say_command.call('Hello', 'world')
#=> returns a result with value 'Hello, world!'
```

Next, we create a curried command. Here, we pass in one argument. This will set the first argument to always be "Greetings"; therefore, our curried command only takes one argument, the name of the person being greeted.

```ruby
greet_command = say_command.curry('Greetings')
greet_command.call('programs')
#=> returns a result with value 'Greetings, programs!'
```

Alternatively, we could pass both arguments to `#curry`. In this case, our curried argument does not take any arguments, and will always return the same string.

```ruby
recruit_command = say_command.curry('Greetings', 'starfighter')
recruit_command.call
#=> returns a result with value 'Greetings, starfighter!'
```

##### Currying Keywords

We can also pass keywords to `#curry`. Again, we start by defining our base command. In this case, our base command takes a mathematical operation (addition, subtraction, multiplication, etc) and a list of operands.

```ruby
math_command = Cuprum::Command.new do |operands:, operation:|
  operations.reduce(&operation)
end
math_command.call(operands: [2, 2], operation: :+)
#=> returns a result with value 4
```

Our curried command still takes two keywords, but now the operation keyword is optional. It now defaults to :\*, for multiplication.

```ruby
multiply_command = math_command.curry(operation: :*)
multiply_command.call(operands: [3, 3])
#=> returns a result with value 9
```

### Composing Commands

Because Cuprum::Command instances are proper objects, they can be composed like any other object. For example, we could define some basic mathematical operations by composing commands:

```ruby
increment_command = Cuprum::Command.new { |i| i + 1 }
increment_command.call(1).value #=> 2
increment_command.call(2).value #=> 3
increment_command.call(3).value #=> 4

add_command = Cuprum::Command.new do |addend, i|
  # Here, we are composing commands together by calling the increment_command
  # instance from inside the add_command definition.
  addend.times { i = increment_command(i).value }

  i
end

add_command.call(1, 1).value #=> 2
add_command.call(1, 2).value #=> 3
add_command.call(2, 1).value #=> 3
add_command.call(2, 2).value #=> 4
```

This can also be done using command classes.

```ruby
class IncrementCommand < Cuprum::Command
  private

  def process i
    i + 1
  end
end

class AddCommand < Cuprum::Command
  def initialize addend
    @addend = addend
  end

  private

  def increment_command
    @increment_command ||= IncrementCommand.new
  end

  def process i
    addend.times { i = increment_command.call(i).value }

    i
  end
end

add_two_command = AddCommand.new(2)
add_two_command.call(0).value #=> 2
add_two_command.call(1).value #=> 3
add_two_command.call(8).value #=> 10
```

You can achieve even more powerful composition by passing in a command as an argument to a method, or by creating a method that returns a command.

#### Commands As Arguments

Since commands are objects, they can be passed in as arguments to a method or to another command. For example, consider a command that calls another command a given number of times:

```ruby
class RepeatCommand
  def initialize(count)
    @count = count
  end

  private

  def process(command)
    @count.times { command.call }
  end
end

greet_command  = Cuprum::Command.new { puts 'Greetings, programs!' }
repeat_command = RepeatCommand.new(3)
repeat_command.call(greet_command) #=> prints 'Greetings, programs!' 3 times
```

This is an implementation of the Strategy pattern, which allows us to customize the behavior of a part of our system by passing in implementation code rather than burying conditionals in our logic.

Consider a more concrete example. Suppose we are running an online bookstore that sells both physuical and electronic books, and serves both domestic and international customers. Depending on what the customer ordered and where they live, our business logic for fulfilling an order will have different shipping instructions.

Traditionally this would be handled with a conditional inside the order fulfillment code, which adds complexity. However, we can use the Strategy pattern and pass in our shipping code as a command.

```ruby
class DeliverEbook < Cuprum::Command; end

class ShipDomestic < Cuprum::Command; end

class ShipInternational < Cuprum::Command; end

class FulfillOrder < Cuprum::Command
  def initialize(delivery_command)
    @delivery_command = delivery_command
  end

  private

  def process(book:, user:)
    # Here we will check inventory, process payments, and so on. The final step
    # is actually delivering the book to the user:
    delivery_command.call(book: book, user: user)
  end
end
```

This pattern is also useful for testing. When writing specs for the FulfillOrder command, simply pass in a mock double as the delivery command. This removes any need to stub out the implementation of whatever shipping method is used (or worse, calls to external services).

#### Commands As Returned Values

We can also return commands as an object from a method call or from another command. One use case for this is the Abstract Factory pattern.

Consider our shipping example, above. The traditional way to generate a shipping command is to use an `if-then-else` or `case` construct, which would be embedded in whatever code is calling `FulfillOrder`. This adds complexity and increases the testing burden.

Instead, let's create a factory command. This command will take a user and a book, and will return the command used to ship that item.

```ruby
class ShippingMethod < Cuprum::Command
  private

  def process(book:, user:)
    return DeliverEbook.new(user.email) if book.ebook?

    return ShipDomestic.new(user.address) if user.address&.domestic?

    return ShipInternational.new(user.address) if user.address&.international?

    err = Cuprum::Error.new(message: 'user does not have a valid address')

    failure(err)
  end
end
```

Notice that our factory includes error handling - if the user does not have a valid address, that is handled immediately rather than when trying to ship the item.

The [Command Factory](#label-Command+Factories) defined by Cuprum is another example of using the Abstract Factory pattern to return command instances. One use case for a command factory would be defining CRUD operations for data records. Depending on the class or the type of record passed in, the factory could return a generic command or a specific command tied to that specific record type.

### Command Steps

Separating out business logic into commands is a powerful tool, but it does come with some overhead, particularly when checking whether a result is passing, or when converting between results and values. When a process has many steps, each of which can fail or return a value, this can result in a lot of boilerplate.

The solution Cuprum provides is the `#step` method, which calls either a named method or a given block. If the result of the block or method is passing, then the `#step` method returns the value of the result.

```ruby
triple_command = Cuprum::Command.new { |i| success(3 * i) }

int = 2
int = step { triple_command.call(int) } #=> returns 6
int = step { triple_command.call(int) } #=> returns 18
```

Notice that in each step, we are returning the *value* of the result from `#step`, not the result itself. This means we do not need explicit calls to the `#value` method.

Of course, not all commands return a passing result. If the result of the block or method is failing, then `#step` will throw `:cuprum_failed_result` and the result, immediately halting the execution chain. If the `#step` method is used inside a command definition (or inside a `#steps` block; [see below](#label-Using+Steps+Outside+Of+Commands)), that symbol will be caught and the failing result returned by `#call`.

```ruby
divide_command = Cuprum::Command.new do |dividend, divisor|
  return failure('divide by zero') if divisor.zero?

  success(dividend / divisor)
end

value = step { divide_command.call(10, 5) } #=> returns 2
value = step { divide_command.call(2, 0) }  #=> throws :cuprum_failed_result
```

Here, the `divide_command` can either return a passing result (if the divisor is not zero) or a failing result (if the divisor is zero). When wrapped in a `#step`, the failing result is then thrown, halting execution.

This is important when using a sequence of steps. Let's consider a case study - reserving a book from the library. This entails several steps, each of which could potentially fail:

- Validating that the user can reserve books. Maybe the user has too many unpaid fines.
- Finding the requested book in the library system. Maybe the requested title isn't in the system.
- Placing a reservation on the book. Maybe there are no copies of the book available to reserve.

Using `#step`, as soon as one of the subtasks fails then the command will immediately return the failed value. This prevents us from hitting later subtasks with invalid data, it returns the actual failing result for analytics and for displaying a useful error message to the user, and it avoids the overhead (and the boilerplate) of exception-based failure handling.

```ruby
class CheckUserStatus < Cuprum::Command; end

class CreateBookReservation < Cuprum::Command; end

class FindBookByTitle < Cuprum::Command; end

class ReserveBookByTitle < Cuprum::Command
  private

  def process(title:, user:)
    # If CheckUserStatus fails, #process will immediately return that result.
    # For this step, we already have the user, so we don't need to use the
    # result value.
    step { CheckUserStatus.new.call(user) }

    # Here, we are looking up the requested title. In this case, we will need
    # the book object, so we save it as a variable. Notice that we don't need
    # an explicit #value call - #step handles that for us.
    book = step { FindBookByTitle.new.call(title) }

    # Finally, we want to reserve the book. Since this is the last subtask, we
    # don't strictly need to use #step. However, it's good practice, especially
    # if we might need to add more steps to the command in the future.
    step { CreateBookReservation.new.call(book: book, user: user) }
  end
end
```

First, our user may not have borrowing privileges. In this case, `CheckUserStatus` will fail, and neither of the subsequent steps will be called. The `#call` method will return the failing result from `CheckUserStatus`.

```ruby
result = ReserveBookByTitle.new.call(
  title: 'The C Programming Language',
  user:  'Ed Dillinger'
)
result.class    #=> Cuprum::Result
result.success? #=> false
result.error    #=> 'not authorized to reserve book'
```

Second, our user may be valid but our requested title may not exist in the system. In this case, `FindBookByTitle` will fail, and the final step will not be called. The `#call` method will return the failing result from `FindBookByTitle`.

```ruby
result = ReserveBookByTitle.new.call(
  title: 'Using GOTO For Fun And Profit',
  user:  'Alan Bradley'
)
result.class    #=> Cuprum::Result
result.success? #=> false
result.error    #=> 'title not found'
```

Third, our user and book may be valid, but all of the copies are checked out. In this case, each of the steps will be called, and the `#call` method will return the failing result from `CreateBookReservation`.

```ruby
result = ReserveBookByTitle.new.call(
  title: 'Design Patterns: Elements of Reusable Object-Oriented Software',
  user:  'Alan Bradley'
)
result.class    #=> Cuprum::Result
result.success? #=> false
result.error    #=> 'no copies available'
```

Finally, if each of the steps succeeds, the `#call` method will return the result of the final step.

```ruby
result = ReserveBookByTitle.new.call(
  title: 'The C Programming Language',
  user:  'Alan Bradley'
)
result.class    #=> Cuprum::Result
result.success? #=> true
result.value    #=> an instance of BookReservation
```

#### Using Methods As Steps

Steps can also be defined as method calls. Instead of providing a block to `#step`, provide the name of the method as the first argument, either as a symbol or as a string. Any subsequent arguments, keywords, or a block is passed to the method when it is called.

A step defined with a method behaves the same as a step defined with a block. If the method returns a successful result, then `#step` will return the value of the result. If the method returns a failing result, then `#step` will throw `:cuprum_failed_result` and the result, to be caught by the `#process` method or the containing `#steps` block.

We can use this to rewrite our `ReserveBookByTitle` command to use methods:

```ruby
class ReserveBookByTitle < Cuprum::Result
  private

  def check_user_status(user)
    CheckUserStatus.new(user)
  end

  def create_book_reservation(book:, user:)
    CreateBookReservation.new(book: book, user: user)
  end

  def find_book_by_title(title)
    FindBookByTitle.new.call(title)
  end

  def process(title:, user:)
    step :check_user_status, user

    book = step :find_book_by_title, title

    create_book_reservation, book: book, user: user
  end
end
```

In this case, our methods simply delegate to our previously defined commands. However, a more complex example could include other logic in each method, or even a sequence of steps defining subtasks for the method. The only requirement is that the method returns a result. You can use the `#success` helpers to wrap a non-result value, or the `#failure` helper to generate a failing result.

#### Using Steps Outside Of Commands

Steps can also be used outside of a command. For example, a controller action might define a sequence of steps to run when the corresponding endpoint is called.

To use steps outside of a command, include the `Cuprum::Steps` module. Then, each sequence of steps should be wrapped in a `#steps` block as follows:

```ruby
steps do
  step { check_something }

  obj = step { find_something }

  step :do_something, with: obj
end
```

Each step will be executed in sequence until a failing result is returned by the block or method. The `#steps` block will return that failing result. If no step returns a failing result, then the return value of the block will be wrapped in a result and returned by `#steps`.

Let's consider the example of a controller action for creating a new resource. This would have several steps, each of which can fail:

- First, we build a new instance of the resource with the provided attributes. This can fail if the attributes are incompatible with the resource, e.g. with extra attributes not included in the resource's table columns.
- Second, we run validations on the resource itself. This can fail if the attributes do not match the expected format.
- Finally, we persist the resource to the database. This can fail if the record violates any database constraints, or if the database itself is unavailable.

```ruby
class BooksController
  include Cuprum::Steps

  def create
    attributes = params[:books]
    result     = steps do
      @book = step :build_book, attributes

      step :run_validations, @book

      step :persist_book, book
    end

    result.success ? redirect_to(@book) : render(:edit)
  end

  private

  def build_book(attributes)
    success(Book.new(attributes))
  rescue InvalidAttributes
    failure('attributes are invalid')
  end

  def persist_book(book)
    book.save ? success(book) : failure('unable to persist book')
  end

  def run_validations(book)
    book.valid? ? success : failure('book is invalid')
  end
end
```

A few things to note about this example. First, we have a couple of examples of wrapping existing code in a result, both by rescuing exceptions (in `#build_book`) or by checking a returned status (in `#persist_book`). Second, note that each of our helper methods can be reused in other controller actions. For even more encapsulation and reusability, the next step might be to convert those methods to commands of their own.

You can define even more complex logic by defining multiple `#steps` blocks. Each block represents a series of tasks that will terminate on the first failure. Steps blocks can even be nested in one another, or inside a `#process` method.

<a id="Results"></a>

### Results

    require 'cuprum'

[Class Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum%2FResult)

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

<a id="Errors"></a>

### Errors

    require 'cuprum/error'

[Class Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum%2FError)

A `Cuprum::Error` encapsulates a specific failure state of a Command. Each Error has a `#message` property, which defaults to nil.

```ruby
error = Cuprum::Error.new
error.message => # nil

error = Cuprum::Error.new(message: 'Something went wrong.')
error.message => # 'Something went wrong.'
```

Each application should define its own failure states as errors. For example, a typical web application might define the following errors:

```ruby
class NotFoundError < Cuprum::Error
  def initialize(resource:, resource_id:)
    @resource    = resource
    @resource_id = resource_id

    super(message: "#{resource} not found with id #{resource_id}")
  end

  attr_reader :resource, :resource_id
end

class ValidationError < Cuprum::Error
  def initialize(resource:, errors:)
    @resource = resource
    @errors   = errors

    super(message: "#{resource} was invalid")
  end

  attr_reader :resource, :errors
end
```

It is optional but recommended to use a `Cuprum::Error` when returning a failed result from a command.

#### Comparing Errors

There are circumstances when it is useful to compare Error objects, such as when writing tests to specify the failure states of a command. To accommodate this, you can pass additional properties to `Cuprum::Error.new` (or to `super` when defining a subclass). These "comparable properties", plus the message, are used to compare the errors.

An instance of `Cuprum::Error` is equal to another (using the `#==` equality comparison) if and only if the two errors have the same `class` and the two errors have the same comparable properties.

```ruby
red     = Cuprum::Error.new(message: 'wrong color', color: 'red')
blue    = Cuprum::Error.new(message: 'wrong color', color: 'blue')
crimson = Cuprum::Error.new(message: 'wrong color', color: 'red')

red == blue
#=> false

red == crimson
#=> true
```

This can be particularly important when defining Error subclasses. By passing the constructor parameters to `super`, below, we will be able to compare different instances of the `NotFoundError`. The errors will only be equal if they have the same message, resource, and resource_id properties.

```ruby
class NotFoundError < Cuprum::Error
  def initialize(resource:, resource_id:)
    @resource    = resource
    @resource_id = resource_id

    super(
      message:     "#{resource} not found with id #{resource_id}",
      resource:    resource,
      resource_id: resource_id,
    )
  end

  attr_reader :resource, :resource_id
end
```

Finally, by overriding the `#comparable_properties` method, you can customize how Error instances are compared.

```ruby
class WrongColorError < Cuprum::Error
  def initialize(color:, shape:)
    super(message: "the #{shape} is the wrong color")

    @color = color
    @shape = shape
  end

  attr_reader :color

  protected

  def comparable_properties
    { color: color }
  end
end
```

<a id="Operations"></a>

### Operations

    require 'cuprum'

[Class Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum%2FOperation)

An Operation is like a Command, but with two key differences. First, an Operation retains a reference to the result object from the most recent time the operation was called, and delegates the methods defined by `Cuprum::Result` to the most recent result. This allows a called Operation to replace a `Cuprum::Result` in any code that expects or returns a result. Second, the `#call` method returns the operation instance, rather than the result itself.

These two features allow developers to simplify logic around calling and using the results of operations, and reduce the need for boilerplate code (particularly when using an operation as part of an existing framework, such as inside of an asynchronous worker or a Rails controller action).

```ruby
class CreateBookOperation < Cuprum::Operation
  def process
    # Implementation here.
  end
end

# Defining a controller action using an operation.
def create
  operation = CreateBookOperation.new.call(book_params)

  if operation.success?
    redirect_to(operation.value)
  else
    @book = operation.value

    render :new
  end
end
```

Like a Command, an Operation can be defined directly by passing an implementation block to the constructor or by creating a subclass that overwrites the #process method.

An operation inherits the `#call` method from Cuprum::Command (see above), and delegates the `#value`, `#error`, `#success?`, and `#failure` methods to the most recent result. If the operation has not been called, these methods will return default values.

#### The Operation Mixin

[Module Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum%2FOperation%2FMixin)

The implementation of `Cuprum::Operation` is defined by the `Cuprum::Operation::Mixin` module, which provides the methods defined above. Any command class or instance can be converted to an operation by including (for a class) or extending (for an instance) the operation mixin.

### Command Factories

[Class Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum%2FCommandFactory)

Commands are powerful and flexible objects, but they do have a few disadvantages compared to traditional service objects which allow the developer to group together related functionality and shared implementation details. To bridge this gap, Cuprum implements the CommandFactory class. Command factories provide a DSL to quickly group together related commands and create context-specific command classes or instances.

For example, consider a basic entity command:

```ruby
class Book
  def initialize(attributes = {})
    @title  = attributes[:title]
    @author = attributes[:author]
  end

  attr_accessor :author, :publisher, :title
end

class BuildBookCommand < Cuprum::Command
  private

  def process(attributes = {})
    Book.new(attributes)
  end
end

class BookFactory < Cuprum::CommandFactory
  command :build, BuildBookCommand
end
```

Our factory is defined by subclassing `Cuprum::CommandFactory`, and then we map the individual commands with the `::command` or `::command_class` class methods. In this case, we've defined a Book factory with the build command. The build command can be accessed on a factory instance in one of two ways.

First, the command class can be accessed directly as a constant on the factory instance.

```ruby
factory = BookFactory.new
factory::Build #=> BuildBookCommand
```

Second, the factory instance now defines a `#build` method, which returns an instance of our defined command class. This command instance can be called like any command, or returned or passed around like any other object.

```ruby
factory = BookFactory.new

attrs   = { title: 'A Wizard of Earthsea', author: 'Ursula K. Le Guin' }
command = factory.build()     #=> an instance of BuildBookCommand
result  = command.call(attrs) #=> an instance of Cuprum::Result
book    = result.value        #=> an instance of Book

book.title     #=> 'A Wizard of Earthsea'
book.author    #=> 'Ursula K. Le Guin'
book.publisher #=> nil
```

#### The ::command Method And A Command Class

The first way to define a command for a factory is by calling the `::command` method and passing it the name of the command and a command class:

```ruby
class BookFactory < Cuprum::CommandFactory
  command :build, BuildBookCommand
end
```

This makes the command class available on a factory instance as `::Build`, and generates the `#build` method which returns an instance of `BuildBookCommand`.

#### The ::command Method And A Block

By calling the `::command` method with a block, you can define a command with additional control over how the generated command. The block must return an instance of a subclass of Cuprum::Command.

```ruby
class PublishBookCommand < Cuprum::Command
  def initialize(publisher:)
    @publisher = publisher
  end

  attr_reader :publisher

  private

  def process(book)
    book.publisher = publisher

    book
  end
end

class BookFactory < Cuprum::CommandFactory
  command :publish do |publisher|
    PublishBookCommand.new(publisher: publisher)
  end
end
```

This defines the `#publish` method on an instance of the factory. The method takes one argument (the publisher), which is then passed on to the constructor for `PublishBookCommand` by our block. Finally, the block returns an instance of the publish command, which is then returned by `#publish`.

```ruby
factory = BookFactory.new
book    = Book.new(title: 'The Tombs of Atuan', author: 'Ursula K. Le Guin')
book.publisher #=> nil

command = factory.publish('Harper & Row') #=> an instance of PublishBookCommand
result  = command.call(book)              #=> an instance of Cuprum::Result
book.publisher #=> 'Harper & Row'
```

Note that unlike when `::command` is called with a command class, calling `::command` with a block will not set a constant on the factory instance. In this case, trying to access the `PublishBookCommand` at `factory::Publish` will raise a `NameError`.

The block is evaluated in the context of the factory instance. This means that instance variables or methods are available to the block, allowing you to create commands with instance-specific configuration.

```ruby
class PublishedBooksCommand < Cuprum::Command
  def initialize(collection = [])
    @collection = collection
  end

  attr_reader :collection

  private

  def process
    books.reject { |book| book.publisher.nil? }
  end
end

class BookFactory < Cuprum::CommandFactory
  def initialize(books)
    @books_collection = books
  end

  attr_reader :books_collection

  command :published do
    PublishedBooksCommand.new(books_collection)
  end
end
```

This defines the `#published` method on an instance of the factory. The method takes no arguments, but grabs the books collection from the factory instance. The block returns an instance of `PublishedBooksCommand`, which is then returned by `#published`.

```ruby
books   = [Book.new, Book.new(publisher: 'Baen'), Book.new(publisher: 'Tor')]
factory = BookFactory.new(books)
factory.books_collection #=> the books array

command = factory.published #=> an instance of PublishedBooksCommand
result  = command.call      #=> an instance of Cuprum::Result
ary     = result.value      #=> an array with the published books

ary.count                                    #=> 2
ary.any? { |book| book.publisher == 'Baen' } #=> true
ary.any? { |book| book.publisher.nil? }      #=> false
```

Simple commands can be defined directly in the block, rather than referencing an existing command class:

```ruby
class BookFactory < Cuprum::CommandFactory
  command :published_by_baen do
    Cuprum::Command.new do |books|
      books.select { |book| book.publisher == 'Baen' }
    end
  end
end

books   = [Book.new, Book.new(publisher: 'Baen'), Book.new(publisher: 'Tor')]
factory = BookFactory.new(books)

command = factory.published_by_baen #=> an instance of the anonymous command
result  = command.call              #=> an instance of Cuprum::Result
ary     = result.value              #=> an array with the selected books

ary.count #=> 1
```

#### The ::command_class Method

The final way to define a command for a factory is calling the `::command_class` method with the command name and a block. The block must return a subclass (not an instance) of Cuprum::Command. This offers a balance between flexibility and power.

```ruby
class SelectByAuthorCommand < Cuprum::Command
  def initialize(author)
    @author = author
  end

  attr_reader :author

  private

  def process(books)
    books.select { |book| book.author == author }
  end
end

class BooksFactory < Cuprum::CommandFactory
  command_class :select_by_author do
    SelectByAuthorCommand
  end
end
```

The command class can be accessed directly as a constant on the factory instance:

```ruby
factory = BookFactory.new
factory::SelectByAuthor #=> SelectByAuthorCommand
```

The factory instance now defines a `#select_by_author` method, which returns an instance of our defined command class. This command instance can be called like any command, or returned or passed around like any other object.

```ruby
factory = BookFactory.new
books   = [
  Book.new,
  Book.new(author: 'Arthur C. Clarke'),
  Book.new(author: 'Ursula K. Le Guin')
]

command = factory.select_by_author('Ursula K. Le Guin')
#=> an instance of SelectByAuthorCommand
command.author #=> 'Ursula K. Le Guin'

result = command.call(books)      #=> an instance of Cuprum::Result
ary    = result.value             #=> an array with the selected books

ary.count                                              #=> 1
ary.any? { |book| book.author == 'Ursula K. Le Guin' } #=> true
ary.any? { |book| book.author == 'Arthur C. Clarke'  } #=> false
ary.any? { |book| book.author.nil? }                   #=> false
```

The block is evaluated in the context of the factory instance. This means that instance variables or methods are available to the block, allowing you to create custom command subclasses with instance-specific configuration.

```ruby
class SaveBookCommand < Cuprum::Command
  def initialize(collection = [])
    @collection = collection
  end

  attr_reader :collection

  private

  def process(book)
    books << book

    book
  end
end

class BookFactory < Cuprum::CommandFactory
  command :save do
    collection = self.books_collection

    Class.new(SaveBookCommand) do
      define_method(:initialize) do
        @books = collection
      end
    end
  end

  def initialize(books)
    @books_collection = books
  end

  attr_reader :books_collection
end
```

The custom command subclass can be accessed directly as a constant on the factory instance:

```ruby
books   = [Book.new, Book.new, Book.new]
factory = BookFactory.new(books)
factory::Save #=> a subclass of SaveBookCommand

command = factory::Save.new # an instance of the command subclass
command.collection          #=> the books array
command.collection.count    #=> 3
```

The factory instance now defines a `#save` method, which returns an instance of our custom command subclass. This command instance can be called like any command, or returned or passed around like any other object.

The custom command subclass can be accessed directly as a constant on the factory instance:

```ruby
books   = [Book.new, Book.new, Book.new]
factory = BookFactory.new(books)
command = factory.save   # an instance of the command subclass
command.collection       #=> the books array
command.collection.count #=> 3

book   = Book.new(title: 'The Farthest Shore', author: 'Ursula K. Le Guin')
result = command.call(book) #=> an instance of Cuprum::Result

books.count          #=> 4
books.include?(book) #=> true
```

### Built In Commands

Cuprum includes a small number of predefined commands and their equivalent operations.

#### IdentityCommand

    require 'cuprum/built_in/identity_command'

[Class Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum%2FBuiltIn%2FIdentityCommand)

A pregenerated command that returns the value or result with which it was called.

```ruby
command = Cuprum::BuiltIn::IdentityCommand.new
result  = command.call('expected value')
result.value    #=> 'expected value'
result.success? #=> true
```

#### IdentityOperation

    require 'cuprum/built_in/identity_operation'

[Class Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum%2FBuiltIn%2FIdentityOperation)

A pregenerated operation that sets its result to the value or result with which it was called.

```ruby
operation = Cuprum::BuiltIn::IdentityOperation.new.call('expected value')
operation.value    #=> 'expected value'
operation.success? #=> true
```

#### NullCommand

    require 'cuprum/built_in/null_command'

[Class Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum%2FBuiltIn%2FNullCommand)

A pregenerated command that does nothing when called. Accepts any arguments.

```ruby
command = Cuprum::BuiltIn::NullCommand.new
result  = command.call
result.value    #=> nil
result.success? #=> true
```

#### NullOperation

    require 'cuprum/built_in/null_operation'

[Class Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum%2FBuiltIn%2FNullOperation)

A pregenerated operation that does nothing when called. Accepts any arguments.

```ruby
operation = Cuprum::BuiltIn::NullOperation.new.call
operation.value    #=> nil
operation.success? #=> true
```

## Reference

Method and class documentation is available courtesy of [RubyDoc](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master).
