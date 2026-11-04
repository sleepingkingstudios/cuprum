---
---

# Cuprum

Cuprum implements the Command pattern for Ruby.

## Documentation

{% include pages/index-versions.md %}

## Getting Started

Add the gem to your `Gemfile` or `gemspec`:

```ruby
gem 'cuprum'
```

Require `Cuprum` in your code:

```ruby
require 'cuprum'
```

To ensure that error message definitions are loaded, call the `Cuprum` initializer:

- In the [initializer](./initializer) for your project:

  ```ruby
  module Space
    @initializer = SleepingKingStudios::Tools::Toolbox::Initializer.new do
      Cuprum.initializer.call
    end
  end
  ```

- Or, in the entry points of your application (such as a `bin` script or `spec_helper.rb`).

## Reference

Cuprum defines the following core components:

- **[Commands](./commands)**
  <br>
  A functional object that responds to `#call` and returns a `Cuprum::Result`.
- **[Results](./results)**
  <br>
  An immutable data object representing the result of a called `Cuprum::Command`. Each `Result` has a `#status` (either `:success` or `:failure`), and may have a `#value`, an `#error`, or both.
- **[Errors](./errors)**
  <br>
  An object representing the failure state of a command.
- **[Factories](./factories)**
  <br>
  Provides a DSL to build commands with shared configuration or context.
- **[Matchers](./matchers)**
  <br>
  Define handling for results based on `#status`, `#error`, and `#value`.

For a full list of defined classes and objects, see [Reference](./reference).
