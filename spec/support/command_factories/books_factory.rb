# frozen_string_literal: true

require 'cuprum/command_factory'

require 'support/commands/build_book'
require 'support/commands/publish_book'
require 'support/commands/save_book_to_collection'
require 'support/errors/not_valid'
require 'support/models/book'

module Spec::CommandFactories
  class BooksFactory < Cuprum::CommandFactory
    command :build, Spec::Commands::BuildBook

    command :publish do |publisher|
      Spec::Commands::PublishBook.new(publisher: publisher)
    end

    command :validate do
      Cuprum::Command.new do |book|
        errors = []

        errors << ['title',  "can't be blank"] if book.title.nil?
        errors << ['author', "can't be blank"] if book.author.nil?

        return book if errors.empty?

        error = Spec::Errors::NotValid.new(
          errors:      errors,
          model_class: book.class
        )

        Cuprum::Result.new(value: book, error: error)
      end
    end

    command_class :save do
      collection = books_collection

      Class.new(Spec::Commands::SaveBookToCollection) do
        define_method(:initialize) do
          super(collection: collection)
        end
      end
    end

    def initialize(books:)
      super()

      @books_collection = books
    end

    attr_reader :books_collection
  end
end
