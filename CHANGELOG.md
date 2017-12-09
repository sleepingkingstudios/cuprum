# Changelog

## 0.7.0

The "To Strive, To Seek, To Find, And Not To Yield" Update.

### Commands

Refactored the `#chain` method. If given a block, will create an anonymous command. The command will be called with the value of the previous result, and additionally the previous result errors, success/failure status, and halted status will be available in the command.

Implemented the `#yield_result` method, which takes a block, yields the previous result, and wraps the return value of the block in a result.

Implemented the `#tap_result` method, which functions as `#yield_result` but always returns the previous result.

Renamed the `#else` method to `#failure`, and the `#then` method to `#success` to avoid overloading reserved words.

Refactored internal logic for returning result objects.

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

## Operations

The implementation of `Cuprum::Operation` has been extracted to a module at `Cuprum::Operation::Mixin`, allowing users to easily convert an existing function class or instance to an operation.

## Results

Implemented `Cuprum::Result#==` as a fuzzy comparison, allowing a result to be equal to any object with the same value and status.

Implemented `Cuprum::Result#empty?`, which returns true for a new result and false for a result with a value, with non-empty errors, a result with set status, or a halted result.

## Utilities

Added the `Cuprum::Utils::InstanceSpy` module to empower testing of code that calls a function without providing a reference, such as some chained functions.

## Built In Functions

Added the `NullFunction` and `NullOperation` predefined classes, which do nothing when called and return a result with no errors and a value of nil.

Added the `IdentityFunction` and `IdentityOperation` predefined classes, which return the value or result which which they were called.

## 0.4.0

The "Halt And Catch Fire" Update.

## Functions

Can now call `#success!` or `#failure!` in a function block or `#process` method to override the default, error-based status for the result. This allows for a passing result that still has errors, or a failing result that does not have explicit errors.

Can now call `#halt!` in a function block or `#process` method. If a function has been halted, then any subsequent chained functions will not be run unless they were chained with the `:on => :always` option.

Can now generate results with custom error objects by overriding the `#build_errors` method.

Fixed an inconsistency issue when a function block or `#process` method returned an instance of `Cuprum::Result`.

## Operations

Calling `#call` on an operation now returns the operation instance.

## Results

Can now call `#success!` or `#failure!` to override the default, error-based status.

Can now call `#halt!` and check the `#halted?` status. A halted result will prevent subsequent chained functions from being run.

## 0.3.0

The "Nothing To Lose But Your Chains" Update.

## Functions

Now support chaining via the `#chain`, `#then`, and `#else` methods.

## Results

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
