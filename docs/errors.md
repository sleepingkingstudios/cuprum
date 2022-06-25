---
breadcrumbs:
  - name: Documentation
    path: './'
---

# Errors

```ruby
require 'cuprum/error'
```

A `Cuprum::Error` encapsulates a specific failure state of a Command.

## Contents

- [Using Errors](#using-errors)
  - [Comparing Errors](#comparing-errors)
  - [Serializing Errors](#serializing-errors)

## Using Errors

Each Error has a `#message` property which defaults to nil. Each Error also has a `#type` property which is determined by the Error class or subclass, although it can be overridden by passing a `:type` parameter to the constructor.

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
  TYPE = 'example.errors.not_found'

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

class ValidationError < Cuprum::Error
  TYPE = 'example.errors.validation'

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

It is optional but recommended to use a `Cuprum::Error` when returning a failed result from a command.

### Comparing Errors

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

### Serializing Errors

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

{% include breadcrumbs.md %}
