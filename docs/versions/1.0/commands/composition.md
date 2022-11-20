---
breadcrumbs:
  - name: Documentation
    path: '../../../'
  - name: Versions
    path: '../../'
  - name: '1.0'
    path: '../'
  - name: Commands
    path: '../commands'
---

# Composing Commands

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
  def initialize(addend)
    @addend = addend
  end

  private

  def increment_command
    @increment_command ||= IncrementCommand.new
  end

  def process(i)
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

## Commands As Arguments

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

## Commands As Returned Values

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

The [Command Factory](../command-factories) defined by Cuprum is another example of using the Abstract Factory pattern to return command instances. One use case for a command factory would be defining CRUD operations for data records. Depending on the class or the type of record passed in, the factory could return a generic command or a specific command tied to that specific record type.

{% include breadcrumbs.md %}
