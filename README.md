# Cuprum

Toolkit for implementing business logic as function objects.

Cuprum defines a Command object, which is a callable object that encapsulates some piece of business logic. Each call to a Command returns a Result with a status and optionally data or an error object. As objects, Commands can be passed as parameters, returned from methods (or other Commands). Commands also define a #step method, which can be used to gracefully handle failure states and define complex operations by combining simpler components.

It defines the following concepts:

- [Commands](http://sleepingkingstudios.github.io/cuprum/commands) - A function-like object that responds to `#call` and returns a `Result`.
- [Operations](http://sleepingkingstudios.github.io/cuprum/commands/operations) - A stateful `Command` that wraps and delegates to its most recent `Result`.
- [Results](http://sleepingkingstudios.github.io/cuprum/results) - An immutable data object with a status (either `:success` or `:failure`), and optional `#value` and/or `#error` objects.
- [Errors](http://sleepingkingstudios.github.io/cuprum/errors) - Encapsulates a failure state of a command.
- [Matchers](http://sleepingkingstudios.github.io/cuprum/matchers) - Define handling for results based on status, error, and value.

Traditional frameworks such as Rails focus on the objects of your application - the "nouns" such as User, Post, or Item. Using Cuprum or a similar library allows you the developer to make your business logic - the "verbs" such as Create User, Update Post or Ship Item - a first-class citizen of your project. This provides several advantages:

- **Consistency:** Use the same Commands to underlie controller actions, worker processes and test factories.
- **Encapsulation:** Each Command is defined and run in isolation, and dependencies must be explicitly provided to the command when it is initialized or run. This makes it easier to reason about the command's behavior and keep it insulated from changes elsewhere in the code.
- **Testability:** Because the logic is extracted from unnecessary context, testing its behavior is much cleaner and easier.
- **Composability:** Complex logic such as "find the object with this ID, update it with these attributes, and log the transaction to the reporting service" can be extracted into a series of simple Commands and composed together. The [step](http://sleepingkingstudios.github.io/cuprum/commands/steps) feature allows for complex control flows.
- **Reusability:** Logic common to multiple data models or instances in your code, such as "persist an object to the database" or "find all records with a given user and created in a date range" can be refactored into parameterized commands.

## Why Cuprum?

Cuprum allows you to define or extract business logic from models, controllers, jobs or freeform services, and to control the flow of that logic by composing together atomic commands. At its heart, Cuprum relies on three features: commands, results, and control flow using steps.

There are a number of other Ruby libraries and frameworks that provide similar solutions, such as [ActiveInteraction](https://github.com/AaronLasseigne/active_interaction), [Interactor](https://github.com/collectiveidea/interactor), and [Waterfall](https://github.com/apneadiving/waterfall). These libraries may focus on only one aspect (e.g. defining commands or control flow), or include features deliberately omitted from Cuprum such as hooks or callbacks.

On the opposite end of the scale, frameworks such as [Dry::Monads](https://dry-rb.org/gems/dry-monads/) or [Trailblazer](http://trailblazer.to/) can also provide similar functionality to Cuprum. These frameworks require a larger commitment to use, particularly for a smaller team or on a smaller project, and often use idiosyncratic syntax that requires a steep learning curve. Cuprum is designed to offer a lightweight alternative that should be much more accessible to new developers.

## Compatibility

Cuprum is tested against Ruby (MRI) 3.1 through 3.3.

## Documentation

Code documentation is generated using [YARD](https://yardoc.org/), and can be generated locally using the `yard` gem.

The full documentation is available via [GitHub Pages](http://sleepingkingstudios.github.io/cuprum), and includes the code documentation as well as a deeper explanation of Cuprum's features and design philosophy. It also includes documentation for prior versions of the gem.

## License

Copyright (c) 2017-2024 Rob Smith

Cuprum is released under the [MIT License](https://opensource.org/licenses/MIT).

## Contribute

The canonical repository for this gem is located at https://github.com/sleepingkingstudios/cuprum.

To report a bug or submit a feature request, please use the [Issue Tracker](https://github.com/sleepingkingstudios/cuprum/issues).

To contribute code, please fork the repository, make the desired updates, and then provide a [Pull Request](https://github.com/sleepingkingstudios/cuprum/pulls). Pull requests must include appropriate tests for consideration, and all code must be properly formatted.

## Code of Conduct

Please note that the `Cuprum` project is released with a [Contributor Code of Conduct](https://github.com/sleepingkingstudios/cuprum/blob/master/CODE_OF_CONDUCT.md). By contributing to this project, you agree to abide by its terms.

## Getting Started

Let's take a look at using Cuprum to define some business logic. Consider the following case study: we are defining an API for a lending library. We'll start by looking at our core models:

- A `Patron` is a user who can borrow books from the library.
- A `Title` represents a book, of which the library may have one or many copies.
- A `PhysicalBook` represents one specific copy of a book. Each `PhysicalBook` belongs to a `Title`, and each `Title` can have zero, one, or many `PhysicalBook`s. A given `PhysicalBook` may or may not be available to lend out (borrowed by a patron, missing, or damaged).
- A `BookLoan` indicates that a specific `PhysicalBook` is either being held for or checked out by a `Patron`.

Some books are more popular than others, so library patrons have asked for a way to reserve a book so they can borrow it when a copy becomes available. We could build this feature in the traditional Rails fashion, but the logic is a bit more complicated and our controller will get kind of messy. Let's try building the logic using commands instead. We've already built our new model:

- A `BookReservation` indicates that a `Patron` is waiting for the next available copy of a `Title`. Whenever the next `PhysicalBook` is available, then the oldest `BookReservation` will convert into a `BookLoan`.

Here is the logic required to fulfill a reserve book request:

- Validate the `Patron` making the request, based on the `patron_id` API parameter.
    - Does the patron exist?
    - Is the patron active?
    - Does the patron have unpaid fines?
- Validate the `Title` requested, based on the `title_id` API parameter.
    - Does the book exist in the system?
    - Are there any physical copies of the book in the system?
- Are all of the physical books checked out?
    - If so, we create a `BookReservation` for the `Title` and the `Patron`.
    - If not, we create a `BookLoan` for a `PhysicalBook` and the `Patron`.

### Defining Commands

Let's get started by handling the `Patron` validation.

```ruby
class FindValidPatron < Cuprum::Command
  private

  def check_active(patron)
    return if patron.active?

    failure(Cuprum::Error.new(message: "Patron #{patron.id} is not active"))
  end

  def check_unpaid_fines(patron)
    return unless patron.unpaid_fines.empty?

    failure(Cuprum::Error.new(message: "Patron #{patron_id} has unpaid fines"))
  end

  def find_patron(patron_id)
    Patron.find(patron_id)
  rescue ActiveRecord::RecordNotFound
    failure(Cuprum::Error.new(message: "Unable to find patron #{patron_id}"))
  end

  def process(patron_id)
    patron = step { find_patron(patron_id) }

    step { check_active(patron) }

    step { check_unpaid_fines(patron) }

    success(patron)
  end
end
```

There's a lot going on there, so let's dig in. We start by defining a subclass of `Cuprum::Command`. Each command must define a `#process` method, which implements the business logic of the command. In our case, `#process` is a method that takes one argument (the `patron_id`) and defines a series of steps.

Steps are a key feature of Cuprum that allows managing control flow through a command. Each `step` has a code block, which can return either a `Cuprum::Result` (either passing or failing) or any Ruby object. If the block returns an object or a passing result, the step passes and returns the object or the result value. However, if the block returns a failing result, then the step fails and halts execution of the command, which immediately returns the failing result.

In our `FindValidPatron` command, we are defining three steps to run in sequence. This allows us to eschew conditional logic - we don't need to assert that a Patron exists before checking whether they are active, because the `step` flow handles that automatically. Looking at the first line in `#process`, we also see that a passing `step` returns the *value* of the result, rather than the result itself - there's no need for an explicit call to `result.value`.

Finally, `Cuprum::Command` defines some helper methods. Each of our three methods includes a `failure()` call. This is a helper method that wraps the given error in a `Cuprum::Result` with status: `:failure`. Likewise, the final line in `#process` has a `success()` call, which wraps the value in a result with status: `:success`.

Let's move on to finding and validating the `Title`.

```ruby
class FindValidTitle < Cuprum::Command
  private

  def find_title(title_id)
    Title.find(title_id)
  rescue ActiveRecord::RecordNotFound
    failure(Cuprum::Error.new(message: "Unable to find title #{title_id}"))
  end

  def has_physical_copies?(title)
    return unless title.physical_books.empty?

    failure(Cuprum::Error.new(message: "No copies of title #{title_id}"))
  end

  def process(title_id)
    title = step { find_title(title_id) }

    step { has_physical_copies?(title) }

    success(title)
  end
end
```

This command is pretty similar to the `FindValidPatron` command. We define a `#process` method that has a few steps, each of which delegates to a helper method. Note that we have a couple of different interaction types here. The `#find_title` method captures exception handling and translates it into a Cuprum result, while the `#has_physical_copies?` method handles conditional logic. We can also see using the first `step` in the `#process` method to easily transition from Cuprum into plain Ruby.

We've captured some of our logic in sub-commands - let's see what it looks like putting it all together.

```ruby
class LoanOrReserveTitle < Cuprum::Command
  private

  def available_copies?(title)
    title.physical_books.any?(&:available?)
  end

  def loan_book(patron:, title:)
    physical_book = title.physical_books.select(&:available?).first
    loan          = BookLoan.new(loanable: physical_book, patron: patron)

    if loan.valid?
      loan.save

      success(loan)
    else
      message = "Unable to loan title #{title.id}:" \
                " #{reservation.errors.full_messages.join(' ')}"
      error   = Cuprum::Error.new(message: message)

      failure(error)
    end
  end

  def process(title_id:, patron_id:)
    patron = step { FindValidPatron.new.call(patron_id) }
    title  = step { FindValidTitle.new.call(title_id) }

    if available_copies?(title)
      loan_book(patron: patron, title: title)
    else
      reserve_title(patron: patron, title: title)
    end
  end

  def reserve_title(patron:, title:)
    reservation = BookReservation.new(patron: patron, title: title)

    if reservation.valid?
      reservation.save

      success(reservation)
    else
      message = "Unable to reserve title #{title.id}:" \
                " #{reservation.errors.full_messages.join(' ')}"
      error   = Cuprum::Error.new(message: message)

      failure(error)
    end
  end
end
```

This command pulls everything together. Instead of using helper methods to power our steps, we are instead using our previously defined commands.

Through the magic of composition, each of the checks we defined in our prior commands is used to gate the control flow - the patron must exist, be active and have no unpaid fines, and the book must exist and have physical copies. If any of those steps fail, the command will halt execution and return the relevant error. Conversely, we're able to encapsulate that logic - reading through `ReserveBook`, we don't need to know the details of what makes a valid patron or book (but if we do need to look into things, we know right where that logic lives and how it was structured).

Finally, we're using plain old Ruby conditionals to determine whether to reserve the book or add the patron to a wait list. Cuprum is a powerful tool, but you don't have to use it for everything - it's specifically designed to be easy to move back and forth between Cuprum and plain Ruby. We could absolutely define a `HasAvailableCopies` command, but we don't have to.

### Using Commands

We've defined our `LoanOrReserveTitle` command. How can we put it to work?

```ruby
command = LoanOrReserveTitle.new

# With invalid parameters.
result = command.call(patron_id: 1_000, title_id: 0)
result.status   #=> :failure
result.success? #=> false
result.error    #=> A Cuprum::Error with message "Unable to find patron 1000"

# With valid parameters.
result = command.call(patron_id: 0, title_id: 0)
result.status   #=> :success
result.success? #=> true
result.value    #=> An instance of BookReservation or WaitingListReservation.
```

Using a `Cuprum` command is simple:

First, instantiate the command. In our case, we haven't defined any constructor parameters, but other commands might. For example, a `SearchRecords` command might take a `record_class` parameter to specify which model class to search.

Second, call the command using the `#call` method. Here, we are passing in `book_id` and `patron_id` keywords. Internally, the command is delegating to the `#process` method we defined (with some additional logic around handling `step`s and ensuring that a result object is returned).

The return value of `#call` will always be a `Cuprum::Result`. Each result has the following properties:

- A `#status`, either `:success` or `:failure`. Also defines corresponding helper methods `#success?` and `#failure?`.
- A `#value`. By convention, most successful results will have a non-`nil` value, such as the records returned by a query.
- An `#error`. Each failing result should have a non-`nil` error. Using an instance of `Cuprum::Error` or a subclass is strongly recommended, but a result error could be a simple message or other errors object.

In rare cases, a result may have both a value and an error, such as the result for a partial query.

Now that we know how to use a command, how can we integrate it into our application? Our original use case is defining an API, so let's build a controller action.

```ruby
class ReservationsController
  def create
    command = LoanOrReserveTitle.new
    result  = command.call(patron_id: patron_id, title_id: title_id)

    if result.failure?
      render json: { ok: false, message: result.error.message }
    elsif result.value.is_a?(BookReservation)
      render json: {
        ok:      true,
        message: "You've been added to the wait list."
      }
    else
      render json: {
        ok:      true,
        message: 'Your book is waiting at your local library!'
      }
    end
  end

  private

  def patron_id
    params.require(:patron_id)
  end

  def title_id
    params.require(:title_id)
  end
end
```

All of the complexity of the business logic is encapsulated in the command definition - all the controller needs to do is call the command and check the result.

### Next Steps

We've defined a command to encapsulate our business logic, and we've incorporated that command into our application. Where can we go from here?

One path forward is extracting out more of the logic into commands. Looking back over our code, we're relying heavily on some of the pre-existing methods on our models. Extracting this logic lets us simplify our models.

We can also use Cuprum to reduce redundancy. Take another look at `LoanOrReserveTitle` - the `#loan_book` and `#reserve_title` helper methods look pretty similar. Both methods take a set of attributes, build a record, validate the record, and then save the record to the database. We can build a command that implements this behavior for any record class.

```ruby
class InvalidRecordError < Cuprum::Error
  def initialize(errors:, message: nil)
    @errors = errors

    super(message: generate_message(message))
  end

  attr_reader :errors

  private

  def generate_message(message)
    "#{message}: #{errors.full_messages.join(' ')}"
  end
end

class CreateRecord
  def initialize(record_class:, short_message: nil)
    @record_class  = record_class
    @short_message = short_message
  end

  attr_reader :record_class

  def short_message
    @short_message ||= "create #{record_class_name}"
  end

  private

  def process(attributes:)
    record = record_class.new(attributes)

    step { validate_record(record) }

    record.save

    success(record)
  end

  def record_class_name
    record_class.name.split('::').last.underscore.tr('_', ' ')
  end

  def validate_record(record)
    return if record.valid?

    error = InvalidRecordError.new(
      errors:  record.errors,
      message: "Unable to #{short_message}"
    )
    failure(error)
  end
end
```

This command is a little more advanced than the ones we've built previously. We start by defining a constructor for the command. This allows us to customize the behavior of the command for each use case, in this case specifying what type of record we are building. We continue using steps to manage control flow and handle errors, and helper methods to keep the `#process` method clean and readable. In a production-ready version of this command, we would probably add additional steps to encompass building the record (which can fail given invalid attribute names) and persisting the record to the database (which can fail even for valid records due to database constraints or unavailable connections).

We're also defining a custom error class, which gives us three benefits. First, it allows us to move some of our presentation logic (the error message) out of the command itself. Second, it lets us pass additional context with the error, in this case the `errors` object for the invalid record object. Third, an error class gives us a method to identify what kind of error occurred.

The latter two are particularly important when handling errors returned by a failing command. For example, an API response for a failed validation might include a JSON object serializing the validation errors. Likewise, the application should have different responses to an `InvalidSession` error (redirect to a login page) compared to a `BookNotFound` error (display a message and return to book selection) or a `PatronUnpaidFines` error (show a link to pay outstanding fines). Using custom error classes allows the application to adapt its behavior based on the type of failure, either with a conventional Ruby conditional or `case` statement, or by using a `Cuprum::Matcher`.

## Dedication

> The lights begin to twinkle from the rocks;\
> The long day wanes; the slow moon climbs; the deep\
> Moans round with many voices. Come, my friends,\
> 'T is not too late to seek a newer world.\
> Push off, and sitting well in order smite\
> The sounding furrows; for my purpose holds\
> To sail beyond the sunset, and the baths\
> Of all the western stars, until I die.\
> It may be that the gulfs will wash us down:\
> It may be we shall touch the Happy Isles,\
> And see the great Achilles, whom we knew.\
> Tho' much is taken, much abides; and tho'\
> We are not now that strength which in old days\
> Moved earth and heaven, that which we are, we are;\
> One equal temper of heroic hearts,\
> Made weak by time and fate, but strong in will\
> To strive, to seek, to find, and not to yield.
>
> from Ulysses, by Alfred, Lord Tennyson
