# Cuprum

A lightweight, functional-lite toolkit for making business logic a first-class
citizen of your application.

## Support

Cuprum is tested against Ruby 2.4.

## Contribute

### GitHub

The canonical repository for this gem is located at https://github.com/sleepingkingstudios/cuprum.

### A Note From The Developer

Hi, I'm Rob Smith, a Ruby Engineer and the developer of this library. I use these tools every day, but they're not just written for me. If you find this project helpful in your own work, or if you have any questions, suggestions or critiques, please feel free to get in touch! I can be reached on GitHub (see above, and feel encouraged to submit bug reports or merge requests there) or via email at merlin@sleepingkingstudios.com. I look forward to hearing from you!

## Features

### Functions

Functions are the core feature of Cuprum. In a nutshell, each Cuprum::Function is a functional object that encapsulates a business logic operation. A Function provides a consistent interface and tracking of result value and status. This minimizes boilerplate and allows for interchangeability between different implementations or strategies for managing your data and processes.

Each Function implements a `#call` method that wraps your defined business logic and returns an instance of Cuprum::Result. The result wraps the returned data (with the `#value` method), any `#errors` generated when running the Function, and the overall status with the `#success?` and `#failure` methods. For more details about Cuprum::Result, see below.

#### Defining With a Block

Functions can be used right out of the box by passing a block to the Cuprum::Function constructor, as follows:

    # A Function with a block
    double_function = Function.new { |int| 2 * int }
    result          = double_function.call(5)

    result.value #=> 10

The constructor block will be called each time `Function#call` is executed, and will be passed all of the arguments given to `#call`. You can even define a block parameter, which will be passed along to the constructor block when `#call` is called with a block argument.

#### Defining With a Subclass

Larger applications will want to create Function subclasses that encapsulate their business logic in a reusable, composable fashion. The implementation for each subclass is handled by the `#process` private method. If a subclass or its ancestors does not implement `#process`, a `Cuprum::Function::NotImplementedError` will be raised.

    # A Function subclass
    class MultiplyFunction
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

#### Success, Failure, and Errors

Whether defined with a block or in the `#process` method, the Function implementation can access an `#errors` object while in the `#call` method. Any errors added to the errors object will be exposed by the `#errors` method on the result object.

    # A Function with errors
    class DivideFunction
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

### Operations

An Operation is like a Function, but with an additional trick of tracking its own most recent execution result. This allows us to simplify some conditional logic, especially boilerplate code used to interact with frameworks.

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

In addition, an operation defines the following methods:

#### `#result`

The most recent result, from the previous time `#call` was executed for the operation.

#### `#called?`

True if the operation has been called and there is a result available by calling `#result` or one of the delegated methods, otherwise false.

#### `#reset!`

Clears the most recent result and resets `#called?` to false. This frees the result and any linked data for garbage collection. It also clears any internal state from the operation.

### Results

A Cuprum::Result is a data object that encapsulates the result of calling a Cuprum function - the returned value, the success or failure status, and any errors generated by the function. It defines the following methods:

#### `#value`

The value returned by the function. For example, for an increment function that added 1 to a given integer, the `#value` of the result object would be the incremented integer.

#### `#errors`

The errors generated by the function, or an empty array if no errors were generated.

#### `#success?`

True if the function did not generate any errors, otherwise false.

#### `#failure?`

True if the function generated one or more errors, otherwise false.
