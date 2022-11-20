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

# Command Currying

Cuprum::Command defines the `#curry` method, which allows for partial application of command objects. Partial application (more commonly referred to, if imprecisely, as currying) refers to fixing some number of arguments to a function, resulting in a function with a smaller number of arguments.

In Cuprum's case, a curried (partially applied) command takes an original command and pre-defines some of its arguments. When the curried command is called, the predefined arguments and/or keywords will be combined with the arguments passed to #call.

## Currying Arguments

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

## Currying Keywords

We can also pass keywords to `#curry`. Again, we start by defining our base command. In this case, our base command takes a mathematical operation (addition, subtraction, multiplication, etc) and a list of operands.

```ruby
math_command = Cuprum::Command.new do |operands:, operation:|
  operations.reduce(&operation)
end
math_command.call(operands: [2, 2], operation: :+)
#=> returns a result with value 4
```

Our curried command still takes two keywords, but now the operation keyword is optional. It now defaults to `:*`, for multiplication.

```ruby
multiply_command = math_command.curry(operation: :*)
multiply_command.call(operands: [3, 3])
#=> returns a result with value 9
```

{% include breadcrumbs.md %}
