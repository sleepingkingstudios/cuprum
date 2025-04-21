---
breadcrumbs:
  - name: Documentation
    path: '../'
  - name: Commands
    path: '../commands'
---

# Parameter Validation

The `Cuprum::ParameterValidation` module defines a DSL for validating a command's parameters prior to evaluating `#process`.

```ruby
require 'cuprum/parameter_validation'

class LaunchRocket < Cuprum::Command
  include Cuprum::ParameterValidation

  validate :rocket, Rocket

  private

  def process(rocket)
    rocket.launched = true
  end
end

result = LaunchRocket.new.call
result.success?    #=> false
result.error.class #=> Cuprum::Errors::InvalidParameters
result.error.message
#=> 'invalid parameters for LaunchRocket - rocket is not an instance of Rocket'
```

If the parameters fail validation, the command will return a failing result with an instance of `Cuprum::Errors::InvalidParameters`.

When multiple validations fail, the error will include all failure messages, not just the first:

```ruby
class PurchaseItem < Cuprum::Command
  include Cuprum::ParameterValidation

  validate :item_name, :name
  validate :qty,       Integer, as: 'quantity'

  private

  def process(item_name:, qty:); end
end

result = PurchaseItem.new.call(item_name: '', qty: 3.14)
result.error.message
#=> "invalid parameters for PurchaseItem - item_name can't be blank, quantity is not an instance of Integer"
```

Validations are also inherited from parent classes or included modules:

```ruby
class BookCommand < Cuprum::Command
  include Cuprum::ParameterValidation

  validate :book, Book
end

class ReadBookCommand < BookCommand
  validate :book, message: 'already read book' do |book|
    book.unread?
  end

  private

  def process(book); end
end

book   = Book.new(title: 'The Songs of Distant Earth')
result = ReadBookCommand.new.call(book)
result.error.message
#=> "invalid parameters for ReadBookCommand - already read book"
```

## Defining Validations

Parameter validations are defined using the `.validate()` class method.

### Named Validations

Calling `.validate(name)` defines an attribute validation, which delegates to the `#validate_#{name}` method on the command.

```ruby
class LaunchRocket < Cuprum::Command
  include Cuprum::ParameterValidation

  validate :rocket

  private

  def process(rocket); end

  def validate_rocket(rocket, **)
    return 'rocket must be a Rocket' unless rocket.is_a?(Rocket)

    return 'rocket already launched' if rocket.launched?
  end
end
```

If the named method returns a failure message, the validation will fail and the message will be added to the failure messages.

Defining a named validation allows for multiple different failure cases and messages, and also allows subclasses to override the validation behavior.

Validation methods should accept any keywords.

### Block Validations

Calling `.validate(name, &block)` defines a block validation, which evaluates the block for a truthy or falsy value.

```ruby
class LaunchRocket < Cuprum::Command
  include Cuprum::ParameterValidation

  validate :rocket do |rocket|
    rocket.is_a?(Rocket) && !rocket.launched?
  end

  private

  def process(rocket); end
end
```

If the block returns a falsy value, the validation will fail and a message will be added to the failure messages. By default, the failure message for a block is '#{name} is invalid'. This can be customized by calling `.validate()` with the `as:` keyword to override the name, or the `message:` keyword to override the entire message.

Defining a block validation allows for custom logic in a terse syntax.

### Class Validations

Calling `.validate(name, klass)` defines a class validation, which requires the value to be an instance of the given Class or Module.

```ruby
class LaunchRocket < Cuprum::Command
  include Cuprum::ParameterValidation

  validate :rocket, Rocket

  private

  def process(rocket); end
end
```

If the value is not an instance of the Class or Module, the validation will fail and a message will be added to the failure messages. By default, the failure message for a class is '#{name} is not an instance of #{class}'. This can be customized by calling `.validate()` with the `as:` keyword to override the name, or the `message:` keyword to override the entire message.

### Method Validations

Calling `.validate(name, type)` defines a method validation, which calls a named method on the command (if defined) or a standard validation method.

```ruby
class LaunchRocket < Cuprum::Command
  include Cuprum::ParameterValidation

  validate :launch_site, :name

  private

  def process(launch_site); end
end
```

A full list of defined validations can be found at [SleepingKingStudios::Tools](https://github.com/sleepingkingstudios/sleeping_king_studios-tools#assertions). Some of the available validations include:

- `:boolean`: Validates that the value is either `true` or `false`.
- `:name`: Validates that the value is a non-empty `String` or `Symbol`.
- `:presence`: Validates that the value is non-`nil` and non-`empty?`.

Method validations can also reference custom methods defined on the command.

```ruby
class LaunchRocket < Cuprum::Command
  include Cuprum::ParameterValidation

  validate :rocket, :launchable?

  private

  def process(rocket); end

  def validate_launchable?(vehicle, as: 'vehicle')
    unless vehicle.respond_to?(:launch)
      return "#{as} can't be launched"
    end

    return unless vehicle.launched?

    "#{as} has already been launched"
  end
end
```

If the method returns a failure message or an array of messages, the validation will fail and the message(s) will be added to the failure messages.

Method validations can also be defined with the `using:` keyword:

```ruby
class LaunchRocket < Cuprum::Command
  include Cuprum::ParameterValidation

  validate :rocket, using: :has_fuel?

  private

  def has_fuel?(rocket, as: 'rocket')
    return unless rocket&.fuel

    return if rocket.fuel > 0

    "#{as} is out of fuel"
  end

  def process(rocket); end
end
```

Defining a validation with the `using:` keyword specifies the method name directly, without applying automatic `validate_` prefix.

### Testing Parameter Validation

For projects using `RSpec`, there is a deferred example group for quickly verifying a command's parameter validation.

```ruby
RSpec.describe LaunchRocket do
  include RSpec::SleepingKingStudios::Deferred::Consumer
  include Cuprum::RSpec::Deferred::ParameterValidationExamples

  subject(:command) { described_class.new }

  describe '#call' do
    def call_command
      command.call(rocket:)
    end

    describe 'with rocket: nil' do
      let(:rocket) { nil }

      include_deferred 'should validate the parameter',
        :rocket,
        message: 'rocket must be a Rocket'
    end
  end
end
```

The example group requires the presence of a defined `#call_command` method, as in the example above.

{% include breadcrumbs.md %}
