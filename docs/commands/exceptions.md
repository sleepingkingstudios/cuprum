---
breadcrumbs:
  - name: Documentation
    path: '../'
  - name: Commands
    path: '../commands'
---

# Handling Exceptions

Cuprum defines a utility module to rescue uncaught exceptions when calling a command.

```ruby
class UnsafeCommand < Cuprum::Command
  private

  def process
    raise 'Something went wrong.'
  end
end

class SafeCommand < UnsafeCommand
  include Cuprum::ExceptionHandling
end

UnsafeCommand.new.call
#=> raises a StandardError

result = SafeCommand.new.call
#=> a Cuprum::Result
result.error
#=> a Cuprum::Errors::UncaughtException error.
result.error.message
#=> 'uncaught exception in SafeCommand -' \
#   ' StandardError: Something went wrong.'
```

Exception handling is *not* included by default - add `include Cuprum::ExceptionHandling` to your command classes to use this feature.

Exception handling can be temporarily disabled by setting the `ENV['CUPRUM_RERAISE_EXCEPTIONS']` flag; this can be used to debug issues when testing commands.

{% include breadcrumbs.md %}
