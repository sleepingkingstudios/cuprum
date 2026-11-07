---
breadcrumbs:
  - name: Documentation
    path: '/'
---

# Errors

A `Cuprum::Error` encapsulates a specific failure state of a Command.

## Contents

- [Using Errors](#using-errors)
- [Error Types](#error-types)
- [Error Messages](#error-messages)
  - [Messages And Parameters](#messages-and-parameters)
- [Error Backtraces](#error-backtraces)
- [Comparing Errors](#comparing-errors)
- [Serializing Errors](#serializing-errors)

## Using Errors

Every `Cuprum::Error` has two properties, a `#type` and a `#message`.

- The `#type` property provides a unique identifier for what went wrong, and is typically defined by the `Error` class or subclass. Use `error.type` in code when you check or compare the reason for the error. For example, you could write a `case` statement checking for multiple error types, each of which is handled differently in your application.
- The `#message` property is an optional, human-readable description of the problem. Use `error.message` when you are explaining the problem to a human. For example, you could display the error message as a toast message in your application when a request fails or is rejected.

```ruby
error = Cuprum::Error.new
error.message => # nil
error.type    => 'cuprum.error'

error = Cuprum::Error.new(message: 'Something went wrong.')
error.message => # 'Something went wrong.'

error = Cuprum::Error.new(type: 'example.custom_type')
error.type => 'example.custom_type'
```

Each application should define its own failure states as errors. For example, a typical web application might define the following errors:

```ruby
class NotFoundError < Cuprum::Error
  TYPE = 'not_found'

  def initialize(resource:, resource_id:)
    @resource    = resource
    @resource_id = resource_id

    super(
      message:     "#{resource} not found with id #{resource_id}",
      resource:    resource,
      resource_id: resource_id
    )
  end

  attr_reader :resource, :resource_id
end

class ValidationFailedError < Cuprum::Error
  TYPE = 'validation_failed'

  def initialize(resource:, errors:)
    @resource = resource
    @errors   = errors

    super(
      errors:   errors,
      message:  "#{resource} was invalid",
      resource: resource
    )
  end

  attr_reader :resource, :errors
end
```

It is optional but strongly recommended to use a `Cuprum::Error` when returning a failed [result](./results) from a [command](./commands).

[Back to Top](#)

## Error Types

An error's `#type` is a unique identifier of the type of error. The type must be a `String` composed of one or more `snake_case` (or "underscored") segments, joined by period (`.`) characters.  The simplest way to specify an error type is to specify an error type is to pass the `:type` keyword to the constructor:

```
error = Cuprum::Error.new(type: 'example.custom_type')
error.type => 'example.custom_type'
```

As an alternative, you can define a `TYPE` constant for the error class. That type will be used for new instances of the error class (unless a `:type` parameter is passed directly). The recommended practice is to match the `name` of the error `class`, so an error with class `EmailService::UnableToSendError` should have a type of `email_service.unable_to_send`.

```ruby
class Reactor::CoolantCheckError < Error
  TYPE = 'reactor.coolant_check'
end

error = Reactor::CoolantCheckError.new
error.type #=> 'reactor.coolant_check'

error = Reactor::CoolantCheckError.new(type: 'example.custom_type')
error.type #=> 'example.custom_type'
```

[Back to Top](#)

## Error Messages

An error's `#message` is intended to be a human-readable representation of the error. The simplest way to specify an error message is to pass the `:message` keyword to the constructor:

```ruby
error = Cuprum::Error.new(message: 'Something went wrong.')
error.message => # 'Something went wrong.'
```

As an alternative, you can define a `MESSAGE` constant for the error class. That message will be used for new instances of the error class (unless a `:message` parameter is passed directly).

```ruby
class Reactor::CoolantCheckError < Error
  MESSAGE = 'Check reactor coolant.'

  TYPE = 'reactor.coolant_check'
end

error = Reactor::CoolantCheckError.new
error.message #=> 'Check reactor coolant.'

error = Reactor::CoolantCheckError.new(message: 'Reactor coolant low.')
error.message #=> 'Reactor coolant low.'
```

Finally, you can generate error messages automatically based on the error's type, using the <a href="https://www.sleepingkingstudios.com/sleeping_king_studios-tools/tools/messages" target="_blank">Messages tool</a>. This is how `Cuprum` defines the messages for it's built-in errors. To do so, <a href="https://www.sleepingkingstudios.com/sleeping_king_studios-tools/tools/messages#registering-messages" target="">register a message key</a> that matches the `#type` of the error. That message will be automatically used for new instances of the error class (unless a `:message` parameter is passed directly).

```ruby
messages = {
  'reactor' => {
    'coolant_check' => 'ALERT: Check reactor coolant level immediately.'
  }
}
registry = SleepingKingStudios::Tools::Messages::Registry.global

registry.register(scope: 'reactor', hash: messages)

error.message #=> 'ALERT: Check reactor coolant level immediately.'
```

If the message for an error is defined in more than one place (the `:message` parameter, the `MESSAGE` constant, or the `tools.messages` strategy), the error's message will be determined in the following order:

1. First, the `:message` parameter, if any.
2. Second, the value in `tools.messages`, if any, that corresponds to the error `#type`.
3. Finally, the value of the `MESSAGE` constant.

If none of the message definitions are present, the value of `#message` will default to `nil`.

[Back to Top](#)

### Messages And Parameters

Some error messages require parameter values to display to the user. `Cuprum` allows you to define error messages with injected parameter values using the syntax for `Kernel#format`. When the error is instantiated, that value will be filled in using the parameters passed to the error.

```ruby
class Reactor::TemperatureTooHighError < Error
  MESSAGE = 'Reactor too hot - %<temperature>i degrees'

  TYPE = 'reactor.temperature_too_high'
end

error = Reactor::TemperatureTooHighError.new(temperature: 500)
error.message #=> 'Reactor too hot - 500 degrees'
```

Both messages defined using the `MESSAGE` constant and messages defined using the `tools.messages` strategy can use parameterized values. If a required value is missing, a `KeyError` will be raised.

[Back to Top](#)

## Error Backtraces

One disadvantage of returning an Error instead of raising an `Exception` is that an Error does not capture where the failure occurred. Every `Cuprum::Error` object does define a `#backtrace` method, but for performance reasons it will return `nil` by default.

```ruby
error = Cuprum::Error.new
error.backtrace => # nil
```

A captured backtrace will return the data as calling `Kernel#caller`, an `Array` of `String`s that contain file names, line numbers, and so on for each caller frame. There are two ways to configure an error to capture it's backtrace. First, you can pass `backtrace: true` to the error constructor:

```ruby
error = Cuprum::Error.new(backtrace: true)
error.backtrace => # an Array of Strings
```

Alternatively, you can set the `CUPRUM_ERROR_BACKTRACE=true` environment flag to enable backtraces for all error objects. This should probably not be enabled in production, but can be useful for debugging a specific issue.

[Back to Top](#)

## Comparing Errors

There are circumstances when it is useful to compare Error objects, such as when writing tests to specify the failure states of a command. To accommodate this, you can pass additional properties to `Cuprum::Error.new` (or to `super` when defining a subclass). These "comparable properties", plus the type and message (if any), are used to compare the errors.

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

[Back to Top](#)

## Serializing Errors

Some use cases require serializing error objects - for example, rendering an error response as JSON. To handle this, `Cuprum::Error` defines an `#as_json` method, which generates a representation of the error as a `Hash` with `String` keys. By default, this includes the `#type` and `#message` (if any) as well as an empty `:data` Hash.

Subclasses can override this behavior to include additional information in the `:data` Hash, which should always use `String` keys and have values composed of basic types and data structures. For example, if an error is passed a `Class`, consider serializing the name of the class to `:data`.

```ruby
error = Cuprum::Error.new
error.as_json #=> { data: {}, message: nil, type: 'cuprum.error' }

error = Cuprum::Error.new(message: 'Something went wrong.')
error.as_json #=> { data: {}, message: 'Something went wrong.', type: 'cuprum.error' }

error = Cuprum::Error.new(type: 'example.custom_error')
error.as_json #=> { data: {}, message: nil, type: 'example.custom_error' }

class ModuleError < Cuprum::Error
  TYPE = 'example.module_error'

  def initialize(actual:)
    @actual = actual
    message = "Expected a Module, but #{actual.name} is a Class"

    super(actual: actual, message: message)
  end

  attr_reader :actual

  private

  def as_json_data
    { actual: actual.name }
  end
end

error = ModuleError.new(actual: String)
error.as_json #=>
# {
#   data:    { actual: 'String' },
#   message: 'Expected a Module, but String is a Class',
#   type:    'example.module_error'
# }
```

**Important Note:** Be careful when serializing error data - this may expose sensitive information or internal details about your system that you don't want to display to users. Recommended practice is to have a whitelist of serializable errors; all other errors will display a generic error message instead.

[Back to Top](#)
