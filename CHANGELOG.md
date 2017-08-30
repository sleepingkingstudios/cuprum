# Changelog

## 0.4.0

The "Halt And Catch Fire" Update.

## Functions

Can now call `#success!` or `#failure!` in a function block or `#process` method to override the default, error-based status for the result. This allows for a passing result that still has errors, or a failing result that does not have explicit errors.

Can now call `#halt!` in a function block or `#process` method. If a function has been halted, then any subsequent chained functions will not be run unless they were chained with the `:on => :always` option.

Fixed an inconsistency issue when a function block or `#process` method returned an instance of `Cuprum::Result`.

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
