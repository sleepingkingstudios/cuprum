# Cuprum

An opinionated implementation of the Command pattern for Ruby applications. Cuprum wraps your business logic in a consistent, object-oriented interface and features status and error management, composability and control flow management.

It defines the following concepts:

- [Commands](#label-Commands) - A function-like object that responds to `#call` and returns a `Result`.
- [Operations](#label-Operations) - A stateful `Command` that wraps and delegates to its most recent `Result`.
- [Results](#label-Results) - A data object with a `#value`, an `#errors` object, and `#success?` and `#failure?` status methods.

## About

[comment]: # "Status Badges will go here."

Traditional frameworks such as Rails focus on the objects of your application - the "nouns" such as User, Post, or Item. Using Cuprum or a similar library allows you the developer to make your business logic - the "verbs" such as Create User, Update Post or Ship Item - a first-class citizen of your project. This provides several advantages:

- **Consistency:** Use the same Commands to underlie controller actions, worker processes and test factories.
- **Encapsulation:** Each Command is defined and run in isolation, and dependencies must be explicitly provided to the command when it is initialized or run. This makes it easier to reason about the command's behavior and keep it insulated from changes elsewhere in the code.
- **Testability:** Because the logic is extracted from unnecessary context, testing its behavior is much cleaner and easier.
- **Composability:** Complex logic such as "find the object with this ID, update it with these attributes, and log the transaction to the reporting service" can be extracted into a series of simple Commands and composed together. The [Chaining](#label-Chaining) feature allows for complex control flows.
- **Reusability:** Logic common to multiple data models or instances in your code, such as "persist an object to the database" or "find all records with a given user and created in a date range" can be refactored into parameterized commands.

### Alternatives

If you want to extract your logic but Cuprum is not the right solution for you, here are several alternatives:

- Service objects. A common pattern used when first refactoring an application that has outgrown its abstractions. Service objects are simple and let you group related functionality, but they are harder to compose and require firm conventions to tame.
- The [Interactor](https://github.com/collectiveidea/interactor) gem. Provides an `Action` module to implement logic and an `Organizer` module to manage control flow. Supports before, around, and after hooks.
- The [Waterfall](https://github.com/apneadiving/waterfall) gem. Focused more on control flow.
- [Trailblazer](http://trailblazer.to/) Operations. A pipeline-based approach to control flow, and can integrate tightly with other Trailblazer elements.

### Compatibility

Cuprum is tested against Ruby (MRI) 2.4.

### Documentation

Method and class documentation is available courtesy of [RubyDoc](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master).

Documentation is generated using [YARD](https://yardoc.org/), and can be generated locally using the `yard` gem.

### License

Copyright (c) 2017 Rob Smith

Cuprum is released under the [MIT License](https://opensource.org/licenses/MIT).

### Contribute

The canonical repository for this gem is located at https://github.com/sleepingkingstudios/cuprum.

To report a bug or submit a feature request, please use the [Issue Tracker](https://github.com/sleepingkingstudios/cuprum/issues).

To contribute code, please fork the repository, make the desired updates, and then provide a [Pull Request](https://github.com/sleepingkingstudios/cuprum/pulls). Pull requests must include appropriate tests for consideration, and all code must be properly formatted.

### Credits

Hi, I'm Rob Smith, a Ruby Engineer and the developer of this library. I use these tools every day, but they're not just written for me. If you find this project helpful in your own work, or if you have any questions, suggestions or critiques, please feel free to get in touch! I can be reached [on GitHub](https://github.com/sleepingkingstudios/cuprum) or [via email](mailto:merlin@sleepingkingstudios.com). I look forward to hearing from you!

## Concepts

### Commands

    require 'cuprum'

Commands are the core feature of Cuprum. In a nutshell, each Cuprum::Command is a functional object that encapsulates a business logic operation. A Command provides a consistent interface and tracking of result value and status. This minimizes boilerplate and allows for interchangeability between different implementations or strategies for managing your data and processes.

Each Command implements a `#call` method that wraps your defined business logic and returns an instance of Cuprum::Result. The result wraps the returned data (with the `#value` method), any `#errors` generated when running the Command, and the overall status with the `#success?` and `#failure` methods. For more details about Cuprum::Result, [see below](#label-Results).

[Class Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum%2FCommand)

#### Defining Commands

The recommended way to define commands is to create a subclass of `Cuprum::Command` and override the `#process` method.

```ruby
class BuildBookCommand < Cuprum::Command
  def process attributes
    Book.new(attributes)
  end # method process
end # class

command = BuildPostCommand.new
result  = command.call(:title => 'The Hobbit') # an instance of Cuprum::Result
result.value #=> an instance of Book with title 'The Hobbit'
```

There are several takeaways from this example. First, we are defining a custom command class that inherits from `Cuprum::Command`. We are defining the `#process` method, which takes a single `attributes` parameter and returns an instance of `Book`. Then, we are creating an instance of the command, and invoking the `#call` method with an attributes hash. These attributes are passed to our `#process` implementation. Invoking `#call` returns a result, and the `#value` of the result is our new Book.

Because a command is just a Ruby object, we can also pass values to the constructor.

```ruby
class SaveBookCommand < Cuprum::Command
  def initialize repository
    @repository = repository
  end # constructor

  def process book
    @repository.persist(book)
  end # method process
end # class

books = [
  Book.new(:title => 'The Fellowship of the Ring'),
  Book.new(:title => 'The Two Towers'),
  Book.new(:title => 'The Return of the King')
]
command = SaveBookCommand.new(books_repository)
books.each { |book| command.call(book) }
```

Here, we are reusing the same command three times, rather than creating a new save command for each book. Each book is persisted to the `books_repository`. This is also an example of how using commands can simplify code - notice that nothing about the `SaveBookCommand` is specific to the `Book` model. Thus, we could refactor this into a generic `SaveModelCommand`.

A command can also be defined by passing block to `Cuprum::Command.new`.

```ruby
increment_command = Cuprum::Command.new { |int| int + 1 }

increment_command.call(2).value #=> 3
```

Commands defined using `Cuprum::Command.new` are quick to use, but more difficult to read and to reuse. Defining your own command class is recommended if a command definition takes up more than one line, or if the command will be used in more than one place.

#### Success, Failure, and Errors

Whether defined with a block or in the `#process` method, the Command implementation can access an `#errors` object while in the `#call` method. Any errors added to the errors object will be exposed by the `#errors` method on the result object.

```ruby
class PublishBookCommand < Cuprum::Command
  private

  def process book
    if book.cover.nil?
      errors << 'This book does not have a cover.'

      return
    end # if

    book.published = true

    book
  end # method process
end # class
```

In addition, the result object defines `#success?` and `#failure?` predicates. If the result has no errors, then `#success?` will return true and `#failure?` will return false.

```ruby
book = Book.new(:title => 'The Silmarillion', :cover => Cover.new)
book.published? #=> false

result = PublishBookCommand.new.call(book)
result.errors   #=> []
result.success? #=> true
result.failure? #=> false
result.value    #=> book
book.published? #=> true
```

If the result does have errors, `#success?` will return false and `#failure?` will return true.

```ruby
book = Book.new(:title => 'The Silmarillion', :cover => nil)
book.published? #=> false

result = PublishBookCommand.new.call(book)
result.errors   #=> ['This book does not have a cover.']
result.success? #=> false
result.failure? #=> true
result.value    #=> book
book.published? #=> false
```

### Chaining Commands

Because Cuprum::Command instances are proper objects, they can be composed like any other object. Cuprum::Command also defines methods for chaining commands together. When a chain of commands is called, each command in the chain is called in sequence and passed the value of the previous command. The result of the last command in the chain is returned from the chained call.

    class AddCommand < Cuprum::Command
      def initialize addend
        @addend = addend
      end # constructor

      private

      def process int
        int + @addend
      end # method process
    end # class

    double_and_add_one = MultiplyCommand.new(2).chain(AddCommand.new(1))
    result             = double_and_add_one(5)

    result.value #=> 5

For finer control over the returned result, `#chain` can instead be called with a block that yields the most recent result. If the block returns a Cuprum::Result, that result is returned or passed to the next command.

    MultiplyCommand.new(3).
      chain { |result| Cuprum::Result.new(result + 1) }.
      call(3)
    #=> Returns a Cuprum::Result with a value of 10.

Otherwise, the block is still called but the previous result is returned or passed to the next command in the chain.

    AddCommand.new(2).
      chain { |result| puts "There are #{result.value} lights!" }.
      call(2)
    #=> Writes "There are 4 lights!" to STDOUT.
    #=> Returns a Cuprum::Result with a value of 4.

#### Conditional Chaining

The `#chain` method can be passed an optional `:on` keyword, with values of `:success` and `:failure` accepted. If `#chain` is called with `:on => :success`, then the chained command or block will **only** be called if the previous result `#success?` returns true. Conversely, if `#chain` is called with `:on => :failure`, then the chained command will only be called if the previous result `#failure?` returns true.

In either case, execution will then pass to the next command in the chain, which may itself be called or not if it was conditionally chained. Calling a conditional command chain will return the result of the last called command.

The methods `#then` and `#else` serve as shortcuts for `#chain` with `:on => :success` and `:on => :failure`, respectively.

    class EvenCommand < Cuprum::Command
      private

      def process int
        errors << 'errors.messages.not_even' unless int.even?

        int
      end # method process
    end # class

    # The next step in a Collatz sequence is determined as follows:
    # - If the number is even, divide it by 2.
    # - If the number is odd, multiply it by 3 and add 1.
    collatz_command =
      EvenCommand.new.
        then(DivideCommand.new(2)).
        else(MultiplyCommand.new(3).chain(AddCommand.new(1)))

    result = collatz_command.new(5)
    result.value #=> 16

    result = collatz_command.new(16)
    result.value #=> 8

#### Halting A Command Chain

If the `#halt` method is called as part of a Command block or `#process` method, the command chain is halted. Any subsequent chained commands will not be called unless they were chained with the `:on => :always` option. This allows you to terminate a Command chain early without having to raise and rescue an exception.

    panic_command =
      Cuprum::Command.new do |value|
        halt!

        value
      end # command

    result =
      double_command.
        then(panic_command).
        then(AddCommand.new(1)). #=> This is never executed.
        chain(:on => :always) { |count| puts "There are #{count} lights!" }.
        call(2)
    #=> Writes "There are 4 lights!" to STDOUT.

    result.value   #= 4
    result.halted? #=> true

### Results

    require 'cuprum'

[Class Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum%2FResult)

A Cuprum::Result is a data object that encapsulates the result of calling a Cuprum command. Each result has a `#value`, an `#errors` object (defaults to an Array), and status methods `#success?`, `#failure?`, and `#halted?`.

```ruby
value  = 'A result value'.freeze
result = Cuprum::Result.new(value)

result.value    #=> 'A result value'
result.errors   #=> []
result.success? #=> true
result.failure? #=> false
result.halted?  #=> false
```

Adding errors to the `#errors` object will change the status of the result.

```ruby
result.errors << "I'm sorry, something went wrong."
result.success? #=> false
result.failure? #=> true
```

The status can also be overriden with the `#success!` and `#failure!` methods, which will set the status regardless of the presence or absence of errors.

```ruby
result.success!
result.errors   #=> ["I'm sorry, something went wrong."]
result.success? #=> true
result.failure? #=> false
```

### Operations

    require 'cuprum'

[Class Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum%2FOperation)

An Operation is like a Command, but with two key differences. First, an Operation retains a reference to the result object from the most recent time the operation was called, and delegates the methods defined by `Cuprum::Result` to the most recent result. This allows a called Operation to replace a `Cuprum::Result` in any code that expects or returns a result. Second, the `#call` method returns the operation instance, rather than the result itself.

These two features allow developers to simplify logic around calling and using the results of operations, and reduce the need for boilerplate code (particularly when using an operation as part of an existing framework, such as inside of an asynchronous worker or a Rails controller action).

```ruby
class CreateBookOperation < Cuprum::Operation
  def process
    # Implementation here.
  end # method process
end # class

# Defining a controller action using an operation.
def create
  operation = CreateBookOperation.new.call(book_params)

  if operation.success?
    redirect_to(operation.value)
  else
    @book = operation.value

    render :new
  end # if-else
end # create
```

Like a Command, an Operation can be defined directly by passing an implementation block to the constructor or by creating a subclass that overwrites the #process method.

An operation inherits the `#call` method from Cuprum::Command (see above), and delegates the `#value`, `#errors`, `#success?`, and `#failure` methods to the most recent result. If the operation has not been called, these methods will return default values.

#### The Operation Mixin

[Module Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum%2FOperation%2FMixin)

The implementation of `Cuprum::Operation` is defined by the `Cuprum::Operation::Mixin` module, which provides the methods defined above. Any command class or instance can be converted to an operation by including (for a class) or extending (for an instance) the operation mixin.

Finally, the result can be halted using the `#halt` method, which indicates that further chained commands should not be executed.

```ruby
result.halt!
result.halted? #=> true
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

### Cuprum::BuiltIn::IdentityCommand

    require 'cuprum/built_in/identity_command'

[Class Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum%2FBuiltIn%2FIdentityCommand)

Cuprum::BuiltIn::IdentityCommand defines the following methods:

#### `#call`

    call(value) #=> Cuprum::Result

Returns a result, whose `#value` is equal to the given value.

### Cuprum::BuiltIn::IdentityOperation

    require 'cuprum/built_in/identity_operation'

[Class Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum%2FBuiltIn%2FIdentityOperation)

Cuprum::BuiltIn::IdentityOperation defines the following methods:

#### `#call`

    call(value) #=> Cuprum::BuiltIn::IdentityOperation

Sets the last result to a new result, whose `#value` is equal to the given value.

### Cuprum::BuiltIn::NullCommand

    require 'cuprum/built_in/null_command'

[Class Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum%2FBuiltIn%2FNullCommand)

Cuprum::BuiltIn::NullCommand defines the following methods:

#### `#call`

    call(*args, **keywords) { ... } #=> Cuprum::Result

Returns a result with nil value. Any arguments or keywords are ignored.

### Cuprum::BuiltIn::NullOperation

    require 'cuprum/built_in/null_operation'

[Class Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum%2FBuiltIn%2FNullOperation)

Cuprum::BuiltIn::NullOperation defines the following methods:

#### `#call`

    call(*args, **keywords) { ... } #=> Cuprum::BuiltIn::NullOperation

Sets the last result to a result with nil value. Any arguments or keywords are ignored.

### Cuprum::Command

    require 'cuprum'

[Class Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum%2FCommand)

A Cuprum::Command defines the following methods:

#### `#initialize`

    initialize { |*arguments, **keywords, &block| ... } #=> Cuprum::Command

Returns a new instance of Cuprum::Command. If a block is given, the `#call` method will wrap the block and set the result `#value` to the return value of the block. This overrides the implementation in `#process`, if any.

[Method Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum/Command#initialize-instance_method)

#### `#build_errors`

*(Private Method)*

    build_errors() #=> Array

Generates an empty errors object. When the command is called, the result will have its `#errors` property initialized to the value returned by `#build_errors`. By default, this is an array. If you want to use a custom errors object type, override this method in a subclass.

[Method Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum/Command#build_errors-instance_method)

#### #call

    call(*arguments, **keywords) { ... } #=> Cuprum::Result

Executes the logic encoded in the constructor block, or the #process method if no block was passed to the constructor.

[Method Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum/Command#call-instance_method)

#### #chain

    chain(on: nil) { |result| ... } #=> Cuprum::Command

Registers a command or block to run after the current command, or after the last chained command if the current command already has one or more chained command(s). This creates and modifies a copy of the current command. See Chaining Commands, below.

    chain(command, on: nil) #=> Cuprum::Command

The command will be passed the `#value` of the previous command result as its parameter, and the result of the chained command will be returned (or passed to the next chained command, if any).

The block will be passed the #result of the previous command as its parameter. If your use case depends on the status of the previous command or on any errors generated, use the block form of #chain.

If the block returns a Cuprum::Result (or an object responding to #value and #success?), the block result will be returned (or passed to the next chained command, if any). If the block returns any other value (including nil), the #result of the previous command will be returned or passed to the next command.

[Method Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum/Command#chain-instance_method)

#### `#else`

    else(command) #=> Cuprum::Command

Shorthand for `command.chain(:on => :failure)`. Registers a command or block to run after the current command. The chained command will only run if the previous command was unsuccessfully run.

The command will be passed the `#value` of the previous command result as its parameter, and the result of the chained command will be returned (or passed to the next chained command, if any).

    else() { |result| ... } #=> Cuprum::Command

The block will be passed the #result of the previous command as its parameter. If your use case depends on the status of the previous command or on any errors generated, use the block form of #chain.

If the block returns a Cuprum::Result (or an object responding to #value and #success?), the block result will be returned (or passed to the next chained command, if any). If the block returns any other value (including nil), the #result of the previous command will be returned or passed to the next command.

[Method Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum/Command#else-instance_method)

#### `#errors`

*(Private Method)*

    errors() #=> Array

Only available while the Command is being called. Provides access to the errors object of the generated Cuprum::Result, which is by default an instance of Array.

Inside of the Command block or the `#process` method, you can add errors to the result.

    command =
      Cuprum::Command.new do
        errors << "I'm sorry, something went wrong."

        nil
      end # command

    result = command.call
    result.failure?
    #=> true
    result.errors
    #=> ["I'm sorry, something went wrong."]

[Method Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum/Command#errors-instance_method)

#### `#failure!`

    failure!() #=> NilClass

*(Private Method)*

Only available while the Command is being called. If called, marks the result object as failing, even if the result does not have errors.

[Method Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum/Command#failure!-instance_method)

#### `#halt!`

    halt!() #=> NilClass

*(Private Method)*

Only available while the Command is being called. If called, halts the command chain (see Chaining Commands, below). Subsequent chained commands will not be called unless they were chained with the `:on => :always` option.

[Method Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum/Command#halt!-instance_method)

#### `#success!`

    success!() #=> NilClass

*(Private Method)*

Only available while the Command is being called. If called, marks the result object as passing, even if the result has errors.

[Method Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum/Command#success!-instance_method)

#### `#then`

    then(command) #=> Cuprum::Command

Shorthand for `command.chain(:on => :success)`. Registers a command or block to run after the current command. The chained command will only run if the previous command was successfully run.

The command will be passed the `#value` of the previous command result as its parameter, and the result of the chained command will be returned (or passed to the next chained command, if any).

    then() { |result| ... } #=> Cuprum::Command

The block will be passed the #result of the previous command as its parameter. If your use case depends on the status of the previous command or on any errors generated, use the block form of #chain.

If the block returns a Cuprum::Result (or an object responding to #value and #success?), the block result will be returned (or passed to the next chained command, if any). If the block returns any other value (including nil), the #result of the previous command will be returned or passed to the next command.

[Method Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum/Command#then-instance_method)

#### `#yield_result`

    yield_result(on: nil) { |previous_result| } #=> Cuprum::Result

Appends the block to the command chain. When the command is called, the block will be yielded the result of the command (or the last result, if one or more other blocks are chained before). The value returned by the block will be wrapped in a Cuprum::Result and returned by `#call`, or passed to the next block if any blocks are chained after.

If the `on` parameter is omitted, the block will be called if the last result is not halted. If the `on` parameter is set to `:success`, the block will be called if the last result is successful and not halted. If the `on` parameter is set to `:failure`, the block will be called if the last result is failing and not halted. Finally, if the `on` parameter is set to `:always`, the block will always be called, even if the last result is halted.

[Method Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum/Command#yield_result-instance_method)

### Cuprum::Operation

    require 'cuprum'

[Class Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum%2FOperation)

A Cuprum::Operation inherits the methods from Cuprum::Command (see above), and defines the following additional methods:

#### `#called?`

    called?() #=> true, false

True if the operation has been called and there is a result available by calling `#result` or one of the delegated methods, otherwise false.

[Method Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum/Operation#called%3F-instance_method)

#### `#reset!`

    reset!()

Clears the most recent result and resets `#called?` to false. This frees the result and any linked data for garbage collection. It also clears any internal state from the operation.

[Method Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum/Operation#reset!-instance_method)

#### `#result`

    result() #=> Cuprum::Result

The most recent result, from the previous time `#call` was executed for the operation.

[Method Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum/Operation#result-instance_method)

### Cuprum::Result

[Class Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum%2FResult)

A Cuprum::Result defines the following methods:

#### `#==`

    ==(other) #=> true, false

Performs a fuzzy comparison with the other object. At a minimum, the other object must respond to `#value` and `#success?`, and the values of `other.value` and `other.success?` must be equal to the corresponding value on the result. In addition, if the `#failure?`, `#errors`, or `#halted?` methods are defined on the other object, then the value of each defined method is compared to the value on the result. Returns true if all values match, otherwise returns false.

#### `#empty?`

    empty?() #=> true, false

Helper method that returns true for a new result. The method returns false if `result.value` is not nil, if `result.errors` is not empty, if the status has been manually set with `#success!` or `#failure!`, or if the result has been halted.

#### `#errors`

    errors() #=> Array

The errors generated by the command, or an empty array if no errors were generated.

[Method Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum/Result#errors-instance_method)

#### `#failure!`

    failure!() #=> Cuprum::Result

Marks the result as failing and returns the result. Calling `#failure?` will return true, even if the result has no errors.

[Method Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum/Result#failure!-instance_method)

#### `#failure?`

    failure?() #=> true, false

True if the command generated one or more errors or was marked as failing. Otherwise false.

[Method Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum/Result#failure%3F-instance_method)

#### `#halt!`

    halt!() #=> Cuprum::Result

Marks the result as halted and returns the result. Calling `#halted?` will return true.

[Method Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum/Result#halt!-instance_method)

#### `#halted?`

    halted?() #=> true, false

True if the result is halted, which prevents chained commands from executing.

#### `#success!`

    success!() #=> Cuprum::Result

Marks the result as passing and returns the result. Calling `#success?` will return true, even if the result has errors.

[Method Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum/Result#success!-instance_method)

#### `#success?`

    success?() #=> true, false

True if the command did not generate any errors, or the result has errors but was marked as passing. Otherwise false.

[Method Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum/Result#success%3F-instance_method)

#### `#value`

    value() #=> Object

The value returned by the command. For example, for an increment command that added 1 to a given integer, the `#value` of the result object would be the incremented integer.

[Method Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum/Result#value-instance_method)

### Cuprum::Utilities::InstanceSpy

    require 'cuprum/utils/instance_spy'

[Class Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum%2FUtils%2FInstanceSpy)

Utility module for instrumenting calls to the #call method of any instance of a command class. This can be used to unobtrusively test the functionality of code that calls a command without providing a reference to the command instance, such as chained commands or methods that create and call a command instance.

#### `::clear_spies`

    clear_spies() #=> nil

Retires all spies. Subsequent calls to the #call method on command instances will not be mirrored to existing spy objects. Calling this method after each test or example that uses an instance spy is recommended.

    after(:example) { Cuprum::Utils::InstanceSpy.clear_spies }

[Method Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum/Utils/InstanceSpy#clear_spies%3F-instance_method)

#### `::spy_on`

    spy_on(command_class) #=> InstanceSpy
    spy_on(command_class) { |spy| ... } #=> nil

Finds or creates a spy object for the given module or class. Each time that the #call method is called for an object of the given type, the spy's #call method will be invoked with the same arguments and block. If `#spy_on` is called with a block, the instance spy will be yielded to the block; otherwise, the spy will be returned.

    # Observing calls to instances of a command.
    spy = Cuprum::Utils::InstanceSpy.spy_on(CustomCommand)

    expect(spy).to receive(:call).with(1, 2, 3, :four => '4')

    CustomCommand.new.call(1, 2, 3, :four => '4')

    # Observing calls to a chained command.
    spy = Cuprum::Utils::InstanceSpy.spy_on(ChainedCommand)

    expect(spy).to receive(:call)

    Cuprum::Command.new {}.
      chain { |result| ChainedCommand.new.call(result) }.
      call

    # Block syntax
    Cuprum::Utils::InstanceSpy.spy_on(CustomCommand) do |spy|
      expect(spy).to receive(:call)

      CustomCommand.new.call
    end # spy_on

[Method Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum/Utils/InstanceSpy#spy_on%3F-instance_method)
