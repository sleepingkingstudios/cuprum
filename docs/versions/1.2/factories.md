---
breadcrumbs:
  - name: Documentation
    path: '../../'
  - name: Versions
    path: '../'
  - name: '1.2'
    path: './'
---

# Command Factories

Command factories provide a DSL to quickly group together related commands and create context-specific command classes or instances.

## Contents

- [Defining A Factory](#defining-a-factory)
- [Adding Commands](#adding-commands)
  - [Customizing Commands](#customizing-commands)
- [Adding A Custom Command Class](#adding-a-custom-command-class)

## Defining A Factory

Consider a basic command that builds a data object.

```ruby
class Book
  def initialize(attributes = {})
    @title  = attributes[:title]
    @author = attributes[:author]
  end

  attr_accessor :author, :publisher, :title
end

class BuildBookCommand < Cuprum::Command
  private

  def process(attributes = {})
    Book.new(attributes)
  end
end

class BookFactory < Cuprum::CommandFactory
  command :build, BuildBookCommand
end
```

Our factory is defined by subclassing `Cuprum::CommandFactory`, and then we map the individual commands with the `::command` or `::command_class` class methods. In this case, we've defined a Book factory with the build command. The build command can be accessed on a factory instance in one of two ways.

First, the command class can be accessed directly as a constant on the factory instance.

```ruby
factory = BookFactory.new
factory::Build #=> BuildBookCommand
```

Second, the factory instance now defines a `#build` method, which returns an instance of our defined command class. This command instance can be called like any command, or returned or passed around like any other object.

```ruby
factory = BookFactory.new

attrs   = { title: 'A Wizard of Earthsea', author: 'Ursula K. Le Guin' }
command = factory.build()     #=> an instance of BuildBookCommand
result  = command.call(attrs) #=> an instance of Cuprum::Result
book    = result.value        #=> an instance of Book

book.title     #=> 'A Wizard of Earthsea'
book.author    #=> 'Ursula K. Le Guin'
book.publisher #=> nil
```

## Adding Commands

The first way to add a command to a factory is by calling the `::command` method and passing it the name of the command and a command class:

```ruby
class BookFactory < Cuprum::CommandFactory
  command :build, BuildBookCommand
end
```

This makes the command class available on a factory instance as `::Build`, and generates the `#build` method which returns an instance of `BuildBookCommand`.

### Customizing Commands

By calling the `::command` method with a block, you can define a command with additional control over how the generated command. The block must return an instance of a subclass of Cuprum::Command.

```ruby
class PublishBookCommand < Cuprum::Command
  def initialize(publisher:)
    @publisher = publisher
  end

  attr_reader :publisher

  private

  def process(book)
    book.publisher = publisher

    book
  end
end

class BookFactory < Cuprum::CommandFactory
  command :publish do |publisher|
    PublishBookCommand.new(publisher: publisher)
  end
end
```

This defines the `#publish` method on an instance of the factory. The method takes one argument (the publisher), which is then passed on to the constructor for `PublishBookCommand` by our block. Finally, the block returns an instance of the publish command, which is then returned by `#publish`.

```ruby
factory = BookFactory.new
book    = Book.new(title: 'The Tombs of Atuan', author: 'Ursula K. Le Guin')
book.publisher #=> nil

command = factory.publish('Harper & Row') #=> an instance of PublishBookCommand
result  = command.call(book)              #=> an instance of Cuprum::Result
book.publisher #=> 'Harper & Row'
```

Note that unlike when `::command` is called with a command class, calling `::command` with a block will not set a constant on the factory instance. In this case, trying to access the `PublishBookCommand` at `factory::Publish` will raise a `NameError`.

The block is evaluated in the context of the factory instance. This means that instance variables or methods are available to the block, allowing you to create commands with instance-specific configuration.

```ruby
class PublishedBooksCommand < Cuprum::Command
  def initialize(collection = [])
    @collection = collection
  end

  attr_reader :collection

  private

  def process
    books.reject { |book| book.publisher.nil? }
  end
end

class BookFactory < Cuprum::CommandFactory
  def initialize(books)
    @books_collection = books
  end

  attr_reader :books_collection

  command :published do
    PublishedBooksCommand.new(books_collection)
  end
end
```

This defines the `#published` method on an instance of the factory. The method takes no arguments, but grabs the books collection from the factory instance. The block returns an instance of `PublishedBooksCommand`, which is then returned by `#published`.

```ruby
books   = [Book.new, Book.new(publisher: 'Baen'), Book.new(publisher: 'Tor')]
factory = BookFactory.new(books)
factory.books_collection #=> the books array

command = factory.published #=> an instance of PublishedBooksCommand
result  = command.call      #=> an instance of Cuprum::Result
ary     = result.value      #=> an array with the published books

ary.count                                    #=> 2
ary.any? { |book| book.publisher == 'Baen' } #=> true
ary.any? { |book| book.publisher.nil? }      #=> false
```

Simple commands can be defined directly in the block, rather than referencing an existing command class:

```ruby
class BookFactory < Cuprum::CommandFactory
  command :published_by_baen do
    Cuprum::Command.new do |books|
      books.select { |book| book.publisher == 'Baen' }
    end
  end
end

books   = [Book.new, Book.new(publisher: 'Baen'), Book.new(publisher: 'Tor')]
factory = BookFactory.new(books)

command = factory.published_by_baen #=> an instance of the anonymous command
result  = command.call              #=> an instance of Cuprum::Result
ary     = result.value              #=> an array with the selected books

ary.count #=> 1
```

#### Adding A Custom Command Class

The final way to define a command for a factory is calling the `::command_class` method with the command name and a block. The block must return a subclass (not an instance) of Cuprum::Command. This offers a balance between flexibility and power.

```ruby
class SelectByAuthorCommand < Cuprum::Command
  def initialize(author)
    @author = author
  end

  attr_reader :author

  private

  def process(books)
    books.select { |book| book.author == author }
  end
end

class BooksFactory < Cuprum::CommandFactory
  command_class :select_by_author do
    SelectByAuthorCommand
  end
end
```

The command class can be accessed directly as a constant on the factory instance:

```ruby
factory = BookFactory.new
factory::SelectByAuthor #=> SelectByAuthorCommand
```

The factory instance now defines a `#select_by_author` method, which returns an instance of our defined command class. This command instance can be called like any command, or returned or passed around like any other object.

```ruby
factory = BookFactory.new
books   = [
  Book.new,
  Book.new(author: 'Arthur C. Clarke'),
  Book.new(author: 'Ursula K. Le Guin')
]

command = factory.select_by_author('Ursula K. Le Guin')
#=> an instance of SelectByAuthorCommand
command.author #=> 'Ursula K. Le Guin'

result = command.call(books)      #=> an instance of Cuprum::Result
ary    = result.value             #=> an array with the selected books

ary.count                                              #=> 1
ary.any? { |book| book.author == 'Ursula K. Le Guin' } #=> true
ary.any? { |book| book.author == 'Arthur C. Clarke'  } #=> false
ary.any? { |book| book.author.nil? }                   #=> false
```

The block is evaluated in the context of the factory instance. This means that instance variables or methods are available to the block, allowing you to create custom command subclasses with instance-specific configuration.

```ruby
class SaveBookCommand < Cuprum::Command
  def initialize(collection = [])
    @collection = collection
  end

  attr_reader :collection

  private

  def process(book)
    books << book

    book
  end
end

class BookFactory < Cuprum::CommandFactory
  command :save do
    collection = self.books_collection

    Class.new(SaveBookCommand) do
      define_method(:initialize) do
        @books = collection
      end
    end
  end

  def initialize(books)
    @books_collection = books
  end

  attr_reader :books_collection
end
```

The custom command subclass can be accessed directly as a constant on the factory instance:

```ruby
books   = [Book.new, Book.new, Book.new]
factory = BookFactory.new(books)
factory::Save #=> a subclass of SaveBookCommand

command = factory::Save.new # an instance of the command subclass
command.collection          #=> the books array
command.collection.count    #=> 3
```

The factory instance now defines a `#save` method, which returns an instance of our custom command subclass. This command instance can be called like any command, or returned or passed around like any other object.

The custom command subclass can be accessed directly as a constant on the factory instance:

```ruby
books   = [Book.new, Book.new, Book.new]
factory = BookFactory.new(books)
command = factory.save   # an instance of the command subclass
command.collection       #=> the books array
command.collection.count #=> 3

book   = Book.new(title: 'The Farthest Shore', author: 'Ursula K. Le Guin')
result = command.call(book) #=> an instance of Cuprum::Result

books.count          #=> 4
books.include?(book) #=> true
```

{% include breadcrumbs.md %}
