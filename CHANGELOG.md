# Changelog

## 1.3.0

The "A Dream Given Form" Update

As of version 1.3.0, Cuprum will no longer support Ruby 3.0.

### Commands

Updated `Cuprum::ExceptionHandling` to re-raise the exception if the `ENV['CUPRUM_RERAISE_EXCEPTIONS']` flag is set.

Implemented `Command.subclass`, allowing partial application of constructor parameters (including the implementation block).

#### Parameter Validation

Implemented `Cuprum::ParameterValidation`, which provides a DSL for validating a command's parameters prior to evaluating `#process`.

### Errors

**Breaking Change:** Corrected the namespace for `Cuprum::Errors::UncaughtException::TYPE` to remove a reference to `cuprum-collections`. If this causes an issue, update your application to reference the constant, rather than a hard-coded value.

### RSpec

Implemented `Cuprum::RSpec::Deferred::ParameterValidationExamples`, which provide a shortcut for testing commands that use parameter validation.

## 1.2.0

The "Straight On Till Morning" Update

As of version 1.2.0, Cuprum will no longer support Ruby 2.7.

### Results

Added the `#properties` method (aliased as `#to_h`) that wraps the result's `#value`, `#status`, and `#error`. Collecting the properties in one method supports defining results with additional or custom properties, such as a checksum or metadata.

The `Cuprum::Result#==` method was updated to compare the result's properties.

- A result can now be matched against a hash with `:value`, `:status`, and `:error` keys.
- Matching a result against a non-result object with its own `#value`, `#status`, and `#error` methods is now deprecated. Define a `#to_h` method on that object to wrap its properties for comparison with a result.

### RSpec

Updated the `Cuprum::RSpec::BeAResultMatcher` to accept an optional result class.

## 1.1.0

The "Second Star To The Right" Update

Extracted the documentation from the README to a dedicated Jekyll site at http://sleepingkingstudios.github.io/cuprum (or see the /docs directory).

### Commands

Implemented `Cuprum::MapCommand`, which calls its implementation once for each item in the given collection and returns a `ResultList` (see below) containing the results of each call.

### Errors

Added the `Cuprum::Errors::MultipleErrors` error class, which is used when converting a `ResultList` to a singular `Result`.

### Results

Implemented `Cuprum::ResultList`, which implements the `Cuprum::Result` interface and aggregates an ordered list of results (such as the results of running a bulk action).

## 1.0.0

The "Look On My Works, Ye Mighty, and Despair" Update

#### Steps

Removed calling `#step` with a method name.

## 0.11.0

The "One Giant Leap" Update

**Note:** This will be the last feature update before 1.0.

### Commands

Implemented the `#to_proc` method, which allows for constructs such as `array.map(&command)`.

Removed the deprecated chaining mechanic.

#### Currying

Added support for currying block parameters.

#### Exception Handling

Defined `Cuprum::ExceptionHandling` to rescue uncaught errors in commands.

Exception handling is *not* included by default - add `include Cuprum::ExceptionHandling` to your command classes to use this feature.

#### Middleware

Defined `Cuprum::Middleware` to define a wrapper that calls other commands.

#### Steps

Deprecated calling `#step` with a method name.

The error type and message when calling `#steps` without a block has changed.

### Errors

Errors can now define their comparable properties by passing additional keywords to the constructor (or `super` for error subclasses).

Added the `#type` method and property.

Added serialization via the `#as_json` method.

### Matchers

Implemented `Cuprum::Matcher`, which provides a way to handle different result cases.

### RSpec

Added the `#be_callable` macro, which is a wrapper for `#respond_to` that references the `#process` method.

RSpec matchers are no longer automatically included when the macro is required. To use the Cuprum matchers, add `config.include Cuprum::RSpec::Matchers` to your RSpec configuration, or add `include Cuprum::RSpec::Matchers` to your example groups.

## 0.10.0

The "One Small Step" Update

**Note:** This update may have backwards incompatible changes for versions of Ruby before 2.7 when creating commands whose last parameter is an arguments Hash. See [separation of positional and keyword arguments](https://www.ruby-lang.org/en/news/2019/12/12/separation-of-positional-and-keyword-arguments-in-ruby-3-0/) for more information.

### Commands

Implemented the `#curry` method, which performs partial application of arguments or keywords.

#### Chaining

Added deprecation warnings to all chaining methods, and `Cuprum::Command` no longer includes `Cuprum::Chaining` by default. The `Cuprum::Chaining` module will be removed in version 0.11.

#### Steps

Implemented the `#step` method, which extracts the value of the called command (on a success) or halts execution (on a failure).

Implemented the `#steps` method, which wraps a series of steps and returns first failing result, or the the last result if all steps are passing.

## 0.9.1

### Operations

Delegate Operation#status to the most recent result.

### RSpec

The #be_a_passing_result macro now automatically adds a `with_error(nil)` expectation.

- This causes the error (if any) to be displayed when matching a failing result.
- This may break some cases when expecting a passing result that still has an error; in these cases, add an error expectation to the call, e.g. `expect().to be_a_passing_result.with_error(some_error)`.

Improve failure message of BeAResultMatcher under some circumstances.

## 0.9.0

The "'Tis Not Too Late To Seek A Newer World" Update

Major refactoring of Command processing and the Result object. This update is **not** backwards compatible.

### Commands

Removed the `#success` and `#failure` chaining helpers.

Permanently removed the deprecated ResultHelpers mixin.

### Errors

Added `Cuprum::Error`, which encapsulates the failure state of a result. It is *recommended*, but not required, that when creating a failing Result, the `:error` property be set to an instance of `Cuprum::Error`.

### Results

Results are now nominally immutable objects. All mutator methods have been removed, including `#failure!`, `#success!`, and `#update`. The `#empty?` predicate has also been removed.

Updated the constructor to take the following keyword arguments: `:value`, `:error`, and `:status`.

- The status can now be overridden on a new Result by passing in the `:status`.
- Resolves an issue when attempting to instantiate a result with a Hash value.
- *Note:* The value must now be passed in as a keyword.
- *Note:* The `:errors` keyword has been renamed to `:error`.

Removed the `:halted` status.

### Other Changes

Removed the `Cuprum#warn` functionality.

### Upgrade Notes

Anywhere a new `Cuprum::Result` is created directly, update the arguments to match the new `value:` and `error:` keywords.

Anywhere the `#result` is referenced inside a command, instead return the desired value directly, or return a result with the desired error.

Anywhere a command is chained with the `#success` or `#failure` shorthand, use the full `chain(on: :success)` or `chain(on: :failure)` format.

## 0.8.0

The "We Have The Technology" Update.

### Commands

Added protected chaining methods `#chain!`, `#tap_result!` and `#yield_result!`. These methods function as their non-imperative counterparts, but add the chained command or block to the current command instead of a clone.

Removed the ResultHelpers mixin from the default Command class. To use the result helper methods, include Cuprum::ResultHelpers in your command class.

Removed the #build_errors helper - each Result is now responsible for building its own errors object. To use a custom errors object, define a subclass of Cuprum::Result and override its #build_errors method, then update your Command's #build_result method to use your custom result class.

### Command Factory

Implemented the CommandFactory class, which provides a builder interface and DSL for grouping and creating commands with a common purpose or with shared configuration.

## 0.7.0

The "To Strive, To Seek, To Find, And Not To Yield" Update.

### Commands

Refactored the `#chain` method. If given a block, will create an anonymous command. The command will be called with the value of the previous result, and additionally the previous result errors, success/failure status, and halted status will be available in the command.

Implemented the `#yield_result` method, which takes a block, yields the previous result, and wraps the return value of the block in a result.

Implemented the `#tap_result` method, which functions as `#yield_result` but always returns the previous result.

Renamed the `#else` method to `#failure`, and the `#then` method to `#success` to avoid overloading reserved words.

Implemented the `#arity` method, which returns an indication of the number of arguments accepted by the command.

Refactored internal logic for returning result objects.

Fixed a bug causing an erroneous warning to be displayed when `#process` discards an old result with a value.

## 0.6.0

The "By Your Command" Update.

### Commands

Refactored `Cuprum::Function` to `Cuprum::Command` to better reflect its role as an implementation of the Command pattern.

Extracted `Cuprum::BasicCommand` as a base class for all commands, implementing `#call` and its associated methods but not including methods or functionality related to command chains.

Extracted the `Cuprum::Chaining` mixin, which encapsulates all of the methods and functionality necessary to implement command chaining.

### Built In Commands

Refactored `Cuprum::BuiltIn::IdentityFunction` to `Cuprum::BuiltIn::IdentityCommand`.

Refactored `Cuprum::BuiltIn::NullFunction` to `Cuprum::BuiltIn::NullCommand`.

## 0.5.0

The "Name Not Found For NullFunction" Update.

Added the `Cuprum::warn` helper, which prints a warning message. By default, `::warn` delegates to `Kernel#warn`, but can be configured (e.g. to call a Logger) by setting `Cuprum::warning_proc=` with a Proc that accepts one argument (the message to display).

### Operations

The implementation of `Cuprum::Operation` has been extracted to a module at `Cuprum::Operation::Mixin`, allowing users to easily convert an existing function class or instance to an operation.

### Results

Implemented `Cuprum::Result#==` as a fuzzy comparison, allowing a result to be equal to any object with the same value and status.

Implemented `Cuprum::Result#empty?`, which returns true for a new result and false for a result with a value, with non-empty errors, a result with set status, or a halted result.

### Utilities

Added the `Cuprum::Utils::InstanceSpy` module to empower testing of code that calls a function without providing a reference, such as some chained functions.

### Built In Functions

Added the `NullFunction` and `NullOperation` predefined classes, which do nothing when called and return a result with no errors and a value of nil.

Added the `IdentityFunction` and `IdentityOperation` predefined classes, which return the value or result which which they were called.

## 0.4.0

The "Halt And Catch Fire" Update.

### Functions

Can now call `#success!` or `#failure!` in a function block or `#process` method to override the default, error-based status for the result. This allows for a passing result that still has errors, or a failing result that does not have explicit errors.

Can now call `#halt!` in a function block or `#process` method. If a function has been halted, then any subsequent chained functions will not be run unless they were chained with the `:on => :always` option.

Can now generate results with custom error objects by overriding the `#build_errors` method.

Fixed an inconsistency issue when a function block or `#process` method returned an instance of `Cuprum::Result`.

### Operations

Calling `#call` on an operation now returns the operation instance.

### Results

Can now call `#success!` or `#failure!` to override the default, error-based status.

Can now call `#halt!` and check the `#halted?` status. A halted result will prevent subsequent chained functions from being run.

## 0.3.0

The "Nothing To Lose But Your Chains" Update.

### Functions

Now support chaining via the `#chain`, `#then`, and `#else` methods.

### Results

Can pass a value and/or an errors object to the constructor.

## 0.2.0

The "Fully Armed and Operational" Update.

### Operations

Implemented `Cuprum::Operation`. As a Function, but with an additional trick of tracking its own most recent execution result.

## 0.1.0

Initial version.

### Functions

Implemented `Cuprum::Function`. A functional object that encapsulates a business logic operation with a consistent interface and tracking of result value and status.

### Results

Implemented `Cuprum::Result`. A data object that encapsulates the result of calling a Cuprum function.
