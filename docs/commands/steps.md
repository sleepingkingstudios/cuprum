---
breadcrumbs:
  - name: Documentation
    path: '../'
  - name: Commands
    path: '../commands'
---

# Command Steps

Separating out business logic into commands is a powerful tool, but it does come with some overhead, particularly when checking whether a result is passing, or when converting between results and values. When a process has many steps, each of which can fail or return a value, this can result in a lot of boilerplate.

The solution Cuprum provides is the `#step` method, which calls either a named method or a given block. If the result of the block or method is passing, then the `#step` method returns the value of the result.

```ruby
triple_command = Cuprum::Command.new { |i| success(3 * i) }

int = 2
int = step { triple_command.call(int) } #=> returns 6
int = step { triple_command.call(int) } #=> returns 18
```

Notice that in each step, we are returning the *value* of the result from `#step`, not the result itself. This means we do not need explicit calls to the `#value` method.

Of course, not all commands return a passing result. If the result of the block or method is failing, then `#step` will throw `:cuprum_failed_result` and the result, immediately halting the execution chain. If the `#step` method is used inside a command definition (or inside a `#steps` block; [see below](#label-Using+Steps+Outside+Of+Commands)), that symbol will be caught and the failing result returned by `#call`.

```ruby
divide_command = Cuprum::Command.new do |dividend, divisor|
  return failure('divide by zero') if divisor.zero?

  success(dividend / divisor)
end

value = step { divide_command.call(10, 5) } #=> returns 2
value = step { divide_command.call(2, 0) }  #=> throws :cuprum_failed_result
```

Here, the `divide_command` can either return a passing result (if the divisor is not zero) or a failing result (if the divisor is zero). When wrapped in a `#step`, the failing result is then thrown, halting execution.

This is important when using a sequence of steps. Let's consider a case study - reserving a book from the library. This entails several steps, each of which could potentially fail:

- Validating that the user can reserve books. Maybe the user has too many unpaid fines.
- Finding the requested book in the library system. Maybe the requested title isn't in the system.
- Placing a reservation on the book. Maybe there are no copies of the book available to reserve.

Using `#step`, as soon as one of the subtasks fails then the command will immediately return the failed value. This prevents us from hitting later subtasks with invalid data, it returns the actual failing result for analytics and for displaying a useful error message to the user, and it avoids the overhead (and the boilerplate) of exception-based failure handling.

```ruby
class CheckUserStatus < Cuprum::Command; end

class CreateBookReservation < Cuprum::Command; end

class FindBookByTitle < Cuprum::Command; end

class ReserveBookByTitle < Cuprum::Command
  private

  def process(title:, user:)
    # If CheckUserStatus fails, #process will immediately return that result.
    # For this step, we already have the user, so we don't need to use the
    # result value.
    step { CheckUserStatus.new.call(user) }

    # Here, we are looking up the requested title. In this case, we will need
    # the book object, so we save it as a variable. Notice that we don't need
    # an explicit #value call - #step handles that for us.
    book = step { FindBookByTitle.new.call(title) }

    # Finally, we want to reserve the book. Since this is the last subtask, we
    # don't strictly need to use #step. However, it's good practice, especially
    # if we might need to add more steps to the command in the future.
    step { CreateBookReservation.new.call(book: book, user: user) }
  end
end
```

First, our user may not have borrowing privileges. In this case, `CheckUserStatus` will fail, and neither of the subsequent steps will be called. The `#call` method will return the failing result from `CheckUserStatus`.

```ruby
result = ReserveBookByTitle.new.call(
  title: 'The C Programming Language',
  user:  'Ed Dillinger'
)
result.class    #=> Cuprum::Result
result.success? #=> false
result.error    #=> 'not authorized to reserve book'
```

Second, our user may be valid but our requested title may not exist in the system. In this case, `FindBookByTitle` will fail, and the final step will not be called. The `#call` method will return the failing result from `FindBookByTitle`.

```ruby
result = ReserveBookByTitle.new.call(
  title: 'Using GOTO For Fun And Profit',
  user:  'Alan Bradley'
)
result.class    #=> Cuprum::Result
result.success? #=> false
result.error    #=> 'title not found'
```

Third, our user and book may be valid, but all of the copies are checked out. In this case, each of the steps will be called, and the `#call` method will return the failing result from `CreateBookReservation`.

```ruby
result = ReserveBookByTitle.new.call(
  title: 'Design Patterns: Elements of Reusable Object-Oriented Software',
  user:  'Alan Bradley'
)
result.class    #=> Cuprum::Result
result.success? #=> false
result.error    #=> 'no copies available'
```

Finally, if each of the steps succeeds, the `#call` method will return the result of the final step.

```ruby
result = ReserveBookByTitle.new.call(
  title: 'The C Programming Language',
  user:  'Alan Bradley'
)
result.class    #=> Cuprum::Result
result.success? #=> true
result.value    #=> an instance of BookReservation
```

## Using Steps Outside Of Commands

Steps can also be used outside of a command. For example, a controller action might define a sequence of steps to run when the corresponding endpoint is called.

To use steps outside of a command, include the `Cuprum::Steps` module. Then, each sequence of steps should be wrapped in a `#steps` block as follows:

```ruby
steps do
  step { check_something }

  obj = step { find_something }

  step :do_something, with: obj
end
```

Each step will be executed in sequence until a failing result is returned by the block or method. The `#steps` block will return that failing result. If no step returns a failing result, then the return value of the block will be wrapped in a result and returned by `#steps`.

Let's consider the example of a controller action for creating a new resource. This would have several steps, each of which can fail:

- First, we build a new instance of the resource with the provided attributes. This can fail if the attributes are incompatible with the resource, e.g. with extra attributes not included in the resource's table columns.
- Second, we run validations on the resource itself. This can fail if the attributes do not match the expected format.
- Finally, we persist the resource to the database. This can fail if the record violates any database constraints, or if the database itself is unavailable.

```ruby
class BooksController
  include Cuprum::Steps

  def create
    attributes = params[:books]
    result     = steps do
      @book = step :build_book, attributes

      step :run_validations, @book

      step :persist_book, book
    end

    result.success ? redirect_to(@book) : render(:edit)
  end

  private

  def build_book(attributes)
    success(Book.new(attributes))
  rescue InvalidAttributes
    failure('attributes are invalid')
  end

  def persist_book(book)
    book.save ? success(book) : failure('unable to persist book')
  end

  def run_validations(book)
    book.valid? ? success : failure('book is invalid')
  end
end
```

A few things to note about this example. First, we have a couple of examples of wrapping existing code in a result, both by rescuing exceptions (in `#build_book`) or by checking a returned status (in `#persist_book`). Second, note that each of our helper methods can be reused in other controller actions. For even more encapsulation and reusability, the next step might be to convert those methods to commands of their own.

You can define even more complex logic by defining multiple `#steps` blocks. Each block represents a series of tasks that will terminate on the first failure. Steps blocks can even be nested in one another, or inside a `#process` method.

{% include breadcrumbs.md %}
