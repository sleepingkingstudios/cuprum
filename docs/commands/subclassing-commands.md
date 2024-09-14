---
breadcrumbs:
  - name: Documentation
    path: '../'
  - name: Commands
    path: '../commands'
---

# Subclassing Commands

Using the `.subclass` class method, you can define `Cuprum::Command` subclasses that partially apply constructor parameters. Partial application (more commonly referred to, if imprecisely, as currying) refers to fixing some number of arguments to a function, resulting in a function with a smaller number of arguments.

For a command, this means we can quickly define a subclass with a particular implementation:

```ruby
GreetCommand = Cuprum::Command.subclass do |name|
  "Greetings, #{name}!"
end

result = GreetCommand.new.call('programs!')
result.value #=> 'Greetings, programs!'
#=>
```

In addition to the implementation block, we can also pass arguments and keywords to the constructor.

```ruby
class FindEntityCommand < Cuprum::Command
  def initialize(entity_class)
    @entity_class = entity_class
  end

  attr_reader :entity_class

  private

  def process(id)
    entity_class.find(id)
  end
end

result = FindEntityCommand.new(Book).call(0)
result.value #=> #<Book>

FindAuthorCommand = FindEntityCommand.subclass(Author)
FindBookCommand   = FindEntityCommand.subclass(Book)

result = FindBookCommand.new.call(0)
result.value #=> #<Book>
```

Using `.subclass`, we are able to quickly define command classes with specific parameters.

{% include breadcrumbs.md %}
