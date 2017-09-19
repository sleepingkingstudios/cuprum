# Cuprum

A lightweight, functional-lite toolkit for making business logic a first-class
citizen of your application.

## Support

Cuprum is tested against Ruby 2.4.

## Documentation

Method and class documentation is available courtesy of [RubyDoc](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master).

Documentation is generated using [YARD](https://yardoc.org/), and can be generated locally using the `yard` gem.

## Contribute

### GitHub

The canonical repository for this gem is located at https://github.com/sleepingkingstudios/cuprum.

### A Note From The Developer

Hi, I'm Rob Smith, a Ruby Engineer and the developer of this library. I use these tools every day, but they're not just written for me. If you find this project helpful in your own work, or if you have any questions, suggestions or critiques, please feel free to get in touch! I can be reached on GitHub (see above, and feel encouraged to submit bug reports or merge requests there) or via email at merlin@sleepingkingstudios.com. I look forward to hearing from you!

## Functions

    require 'cuprum/function'

[Class Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum%2FFunction)

Functions are the core feature of Cuprum. In a nutshell, each Cuprum::Function is a functional object that encapsulates a business logic operation. A Function provides a consistent interface and tracking of result value and status. This minimizes boilerplate and allows for interchangeability between different implementations or strategies for managing your data and processes.

Each Function implements a `#call` method that wraps your defined business logic and returns an instance of Cuprum::Result. The result wraps the returned data (with the `#value` method), any `#errors` generated when running the Function, and the overall status with the `#success?` and `#failure` methods. For more details about Cuprum::Result, see below.

### Methods

A Cuprum::Function defines the following methods:

#### #initialize

    initialize { |*arguments, **keywords, &block| ... } #=> Cuprum::Function

Returns a new instance of Cuprum::Function. If a block is given, the `#call` method will wrap the block and set the result `#value` to the return value of the block. This overrides the implementation in `#process`, if any.

[Method Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum/Function#initialize-instance_method)

#### #call

    call(*arguments, **keywords) { ... } #=> Cuprum::Result

Executes the logic encoded in the constructor block, or the #process method if no block was passed to the constructor.

[Method Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum/Function#call-instance_method)

#### #chain

Registers a function or block to run after the current function, or after the last chained function if the current function already has one or more chained function(s). This creates and modifies a copy of the current function. See Chaining Functions, below.

    chain(function, on: nil) #=> Cuprum::Function

The function will be passed the `#value` of the previous function result as its parameter, and the result of the chained function will be returned (or passed to the next chained function, if any).

    chain(on: nil) { |result| ... } #=> Cuprum::Function

The block will be passed the #result of the previous function as its parameter. If your use case depends on the status of the previous function or on any errors generated, use the block form of #chain.

If the block returns a Cuprum::Result (or an object responding to #value and #success?), the block result will be returned (or passed to the next chained function, if any). If the block returns any other value (including nil), the #result of the previous function will be returned or passed to the next function.

[Method Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum/Function#chain-instance_method)

#### `#then`

Shorthand for `function.chain(:on => :success)`. Registers a function or block to run after the current function. The chained function will only run if the previous function was successfully run.

    then(function) #=> Cuprum::Function

The function will be passed the `#value` of the previous function result as its parameter, and the result of the chained function will be returned (or passed to the next chained function, if any).

    then() { |result| ... } #=> Cuprum::Function

The block will be passed the #result of the previous function as its parameter. If your use case depends on the status of the previous function or on any errors generated, use the block form of #chain.

If the block returns a Cuprum::Result (or an object responding to #value and #success?), the block result will be returned (or passed to the next chained function, if any). If the block returns any other value (including nil), the #result of the previous function will be returned or passed to the next function.

[Method Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum/Function#then-instance_method)

#### `#else`

Shorthand for `function.chain(:on => :failure)`. Registers a function or block to run after the current function. The chained function will only run if the previous function was unsuccessfully run.

    else(function) #=> Cuprum::Function

The function will be passed the `#value` of the previous function result as its parameter, and the result of the chained function will be returned (or passed to the next chained function, if any).

    else() { |result| ... } #=> Cuprum::Function

The block will be passed the #result of the previous function as its parameter. If your use case depends on the status of the previous function or on any errors generated, use the block form of #chain.

If the block returns a Cuprum::Result (or an object responding to #value and #success?), the block result will be returned (or passed to the next chained function, if any). If the block returns any other value (including nil), the #result of the previous function will be returned or passed to the next function.

[Method Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum/Function#else-instance_method)

#### `#build_errors`

*Private method*. Generates an empty errors object. When the function is called, the result will have its `#errors` property initialized to the value returned by `#build_errors`. By default, this is an array. If you want to use a custom errors object type, override this method in a subclass.

    build_errors() #=> Array

[Method Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum/Function#build_errors-instance_method)

### Implementation Hooks

These methods are only available while the Function is being called, and allow the implementation to update the errors of and override the results of the result object.

#### `#errors`

Only available while the Function is being called. Provides access to the errors object of the generated Cuprum::Result, which is by default an instance of Array.

    errors() #=> Array

Inside of the Function block or the `#process` method, you can add errors to the result.

    function =
      Cuprum::Function.new do
        errors << "I'm sorry, something went wrong."

        nil
      end # function

    result = function.call
    result.failure?
    #=> true
    result.errors
    #=> ["I'm sorry, something went wrong."]

[Method Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum/Function#errors-instance_method)

#### `#success!`

Only available while the Function is being called. If called, marks the result object as passing, even if the result has errors.

    success!() #=> NilClass

#### `#failure!`

Only available while the Function is being called. If called, marks the result object as failing, even if the result does not have errors.

    failure!() #=> NilClass

#### `#halt!`

Only available while the Function is being called. If called, halts the function chain (see Chaining Functions, below). Subsequent chained functions will not be called unless they were chained with the `:on => :always` option.

    halt!() #=> NilClass

### Defining With a Block

Functions can be used right out of the box by passing a block to the Cuprum::Function constructor, as follows:

    # A Function with a block
    double_function = Cuprum::Function.new { |int| 2 * int }
    result          = double_function.call(5)

    result.value #=> 10

The constructor block will be called each time `Function#call` is executed, and will be passed all of the arguments given to `#call`. You can even define a block parameter, which will be passed along to the constructor block when `#call` is called with a block argument.

### Defining With a Subclass

Larger applications will want to create Function subclasses that encapsulate their business logic in a reusable, composable fashion. The implementation for each subclass is handled by the `#process` private method. If a subclass or its ancestors does not implement `#process`, a `Cuprum::Function::NotImplementedError` will be raised.

    # A Function subclass
    class MultiplyFunction < Cuprum::Function
      def initialize multiplier
        @multiplier = multiplier
      end # constructor

      private

      def process int
        int * @multiplier
      end # method process
    end # class

    triple_function = MultiplyFunction.new(3)
    result          = triple_function.call(5)

    result.value #=> 15

As with the block syntax, a Function whose implementation is defined via the `#process` method will call `#process` each time that `#call` is executed, and will pass all arguments from `#call` on to `#process`. The value returned by `#process` will be assigned to the result `#value`.

### Success, Failure, and Errors

Whether defined with a block or in the `#process` method, the Function implementation can access an `#errors` object while in the `#call` method. Any errors added to the errors object will be exposed by the `#errors` method on the result object.

    # A Function with errors
    class DivideFunction < Cuprum::Function
      def initialize divisor
        @divisor = divisor
      end # constructor

      private

      def process int
        if @divisor.zero?
          errors << 'errors.messages.divide_by_zero'

          return
        end # if

        int / @divisor
      end # method process
    end # class

In addition, the result object defines `#success?` and `#failure?` predicates. If the result has no errors, then `#success?` will return true and `#failure?` will return false.

    halve_function = DivideFunction.new(2)
    result         = halve_function.call(10)

    result.errors   #=> []
    result.success? #=> true
    result.failure? #=> false
    result.value    #=> 5

 If the result does have errors, `#success?` will return false and `#failure?` will return true.

    function_with_errors = DivideFunction.new(0)
    result               = function_with_errors.call(10)

    result.errors   #=> ['errors.messages.divide_by_zero']
    result.success? #=> false
    result.failure? #=> true
    result.value    #=> nil

### Chaining Functions

Because Cuprum::Function instances are proper objects, they can be composed like any other object. Cuprum::Function also defines methods for chaining functions together. When a chain of functions is called, each function in the chain is called in sequence and passed the value of the previous function. The result of the last function in the chain is returned from the chained call.

    class AddFunction < Cuprum::Function
      def initialize addend
        @addend = addend
      end # constructor

      private

      def process int
        int + @addend
      end # method process
    end # class

    double_and_add_one = MultiplyFunction.new(2).chain(AddFunction.new(1))
    result             = double_and_add_one(5)

    result.value #=> 5

For finer control over the returned result, `#chain` can instead be called with a block that yields the most recent result. If the block returns a Cuprum::Result, that result is returned or passed to the next function.

    MultiplyFunction.new(3).
      chain { |result| Cuprum::Result.new(result + 1) }.
      call(3)
    #=> Returns a Cuprum::Result with a value of 10.

Otherwise, the block is still called but the previous result is returned or passed to the next function in the chain.

    AddFunction.new(2).
      chain { |result| puts "There are #{result.value} lights!" }.
      call(2)
    #=> Writes "There are 4 lights!" to STDOUT.
    #=> Returns a Cuprum::Result with a value of 4.

#### Conditional Chaining

The `#chain` method can be passed an optional `:on` keyword, with values of `:success` and `:failure` accepted. If `#chain` is called with `:on => :success`, then the chained function or block will **only** be called if the previous result `#success?` returns true. Conversely, if `#chain` is called with `:on => :failure`, then the chained function will only be called if the previous result `#failure?` returns true.

In either case, execution will then pass to the next function in the chain, which may itself be called or not if it was conditionally chained. Calling a conditional function chain will return the result of the last called function.

The methods `#then` and `#else` serve as shortcuts for `#chain` with `:on => :success` and `:on => :failure`, respectively.

    class EvenFunction < Cuprum::Function
      private

      def process int
        errors << 'errors.messages.not_even' unless int.even?

        int
      end # method process
    end # class

    # The next step in a Collatz sequence is determined as follows:
    # - If the number is even, divide it by 2.
    # - If the number is odd, multiply it by 3 and add 1.
    collatz_function =
      EvenFunction.new.
        then(DivideFunction.new(2)).
        else(MultiplyFunction.new(3).chain(AddFunction.new(1)))

    result = collatz_function.new(5)
    result.value #=> 16

    result = collatz_function.new(16)
    result.value #=> 8

#### Halting A Function Chain

If the `#halt` method is called as part of a Function block or `#process` method, the function chain is halted. Any subsequent chained functions will not be called unless they were chained with the `:on => :always` option. This allows you to terminate a Function chain early without having to raise and rescue an exception.

    panic_function =
      Cuprum::Function.new do |value|
        halt!

        value
      end # function

    result =
      double_function.
        then(panic_function).
        then(AddFunction.new(1)). #=> This is never executed.
        chain(:on => :always) { |count| puts "There are #{count} lights!" }.
        call(2)
    #=> Writes "There are 4 lights!" to STDOUT.

    result.value   #= 4
    result.halted? #=> true

## Operations

    require 'cuprum/operation'

[Class Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum%2FOperation)

An Operation is like a Function, but with two key differences. First, an Operation retains a reference to the result object from the most recent time the operation was called and delegates the methods defined by `Cuprum::Result` to the most recent result. This allows a called Operation to replace a `Cuprum::Result` in any code that expects or returns a result. Second, the `#call` method returns the operation instance, rather than the result itself.

These two features allow developers to simplify logic around calling and using the results of operations, and reduce the need for boilerplate code (particularly when using an operation as part of an existing framework, such as inside of an asynchronous worker or a Rails controller action).

    class CreateBookOperation < Cuprum::Operation
      def process
        # Implementation here.
      end # method process
    end # class

    def create
      operation = CreateBookOperation.new.call(book_params)

      if operation.success?
        redirect_to(operation.value)
      else
        @book = operation.value

        render :new
      end # if-else
    end # create

Like a Function, an Operation can be defined directly by passing an implementation block to the constructor or by creating a subclass that overwrites the #process method.

An operation inherits the `#call` method from Cuprum::Function (see above), and delegates the `#value`, `#errors`, `#success?`, and `#failure` methods to the most recent result (see below). If the operation has not been called, the operation will return default values.

### Methods

A Cuprum::Operation inherits the methods from Cuprum::Function (see above), and defines the following additional methods:

#### `#result`

    result() #=> Cuprum::Result

The most recent result, from the previous time `#call` was executed for the operation.

[Method Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum/Operation#result-instance_method)

#### `#called?`

    called?() #=> true, false

True if the operation has been called and there is a result available by calling `#result` or one of the delegated methods, otherwise false.

[Method Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum/Operation#called%3F-instance_method)

#### `#reset!`

    reset!()

Clears the most recent result and resets `#called?` to false. This frees the result and any linked data for garbage collection. It also clears any internal state from the operation.

[Method Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum/Operation#reset!-instance_method)

### The Operation Mixin

[Module Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum%2FOperation%2FMixin)

The implementation of `Cuprum::Operation` is defined by the `Cuprum::Operation::Mixin` module, which provides the methods defined above. Any function class or instance can be converted to an operation by including (for a class) or extending (for an instance) the operation mixin.

## Results

[Class Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum%2FResult)

A Cuprum::Result is a data object that encapsulates the result of calling a Cuprum function - the returned value, the success or failure status, and any errors generated by the function.

    value  = 'A result value'.freeze
    result = Cuprum::Result.new(value)

    result.value
    #=> 'A result value'

### Methods

A Cuprum::Result defines the following methods:

#### `#value`

    value() #=> Object

The value returned by the function. For example, for an increment function that added 1 to a given integer, the `#value` of the result object would be the incremented integer.

[Method Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum/Result#value-instance_method)

#### `#errors`

    errors() #=> Array

The errors generated by the function, or an empty array if no errors were generated.

[Method Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum/Result#errors-instance_method)

#### `#success?`

    success?() #=> true, false

True if the function did not generate any errors, otherwise false.

[Method Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum/Result#success%3F-instance_method)

#### `#failure?`

    failure?() #=> true, false

True if the function generated one or more errors, otherwise false.

[Method Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum/Result#failure%3F-instance_method)

## Built In Functions

Cuprum includes a small number of predefined functions and their equivalent operations.

### IdentityFunction

    require 'cuprum/built_in/identity_function'

[Class Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum%2FBuiltIn%2FIdentityFunction)

A pregenerated function that returns the value or result with which it was called.

    function = Cuprum::BuiltIn::IdentityFunction.new
    result   = function.call('expected value')
    result.value
    #=> 'expected value'
    result.success?
    #=> true

### IdentityOperation

    require 'cuprum/built_in/identity_operation'

[Class Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum%2FBuiltIn%2FIdentityOperation)

A pregenerated operation that sets its result to the value or result with which it was called.

    operation = Cuprum::BuiltIn::IdentityFunction.new.call('expected value')
    operation.value
    #=> 'expected value'
    operation.success?
    #=> true

### NullFunction

    require 'cuprum/built_in/null_function'

[Class Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum%2FBuiltIn%2FNullFunction)

A pregenerated function that does nothing when called.

    function = Cuprum::BuiltIn::NullFunction.new
    result   = function.call
    result.value
    #=> nil
    result.success?
    #=> true

### NullOperation

    require 'cuprum/built_in/null_operation'

[Class Documentation](http://www.rubydoc.info/github/sleepingkingstudios/cuprum/master/Cuprum%2FBuiltIn%2FNullFunction)

A pregenerated operation that does nothing when called.

    operation = Cuprum::BuiltIn::NullOperation.new.call
    operation.value
    #=> nil
    operation.success?
    #=> true
