require 'cuprum/command'
require 'cuprum/command_factory'

module Spec
  class ValidationError < Cuprum::Error
    def initialize(errors:)
      @errors = errors

      super(message: 'Object is not valid.')
    end

    attr_reader :errors
  end

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

  class SaveBookCommand < Cuprum::Command
    attr_accessor :books

    private

    def process(book)
      books << book

      book
    end
  end

  class BookFactory < Cuprum::CommandFactory
    command :build, BuildBookCommand

    command :publish do |publisher|
      Spec::PublishBookCommand.new(publisher: publisher)
    end

    command :validate do
      Cuprum::Command.new do |book|
        errors = []

        errors << "title can't be blank"  if book.title.nil?
        errors << "author can't be blank" if book.author.nil?

        return book if errors.empty?

        error = Spec::ValidationError.new(errors: errors)

        Cuprum::Result.new(value: book, error: error)
      end
    end

    command_class :save do
      collection = books_collection

      Class.new(Spec::SaveBookCommand) do
        define_method(:initialize) do
          @books = collection
        end
      end
    end

    def initialize(books:)
      @books_collection = books
    end

    attr_reader :books_collection
  end
end

RSpec.describe Spec::BookFactory do # rubocop:disable RSpec/FilePath
  subject(:instance) { described_class.new(books: books_collection) }

  let(:books_collection) { [] }

  describe '::Build' do
    it { expect(instance::Build).to be Spec::BuildBookCommand }
  end

  describe '::Save' do
    it { expect(instance::Save).to be_a Class }

    it { expect(instance::Save).to be < Spec::SaveBookCommand }
  end

  describe '#build' do
    let(:attributes) do
      { title: 'A Wizard of Earthsea', author: 'Ursula K. Le Guin' }
    end

    it { expect(instance).to respond_to(:build).with(0).arguments }

    it { expect(instance.build).to be_a Spec::BuildBookCommand }

    it 'should build a book' do
      command = instance.build
      result  = command.call(attributes, **{})
      book    = result.value

      expect(book).to be_a Spec::Book
      expect(book.title).to  be == attributes[:title]
      expect(book.author).to be == attributes[:author]
    end
  end

  describe '#command?' do
    it { expect(instance).to respond_to(:command?).with(1).argument }

    it { expect(instance.command? :burn).to be false }

    it { expect(instance.command? :build).to be true }

    it { expect(instance.command? :publish).to be true }

    it { expect(instance.command? :save).to be true }

    it { expect(instance.command? :validate).to be true }
  end

  describe '#commands' do
    let(:expected) { %i[build save publish validate] }

    include_examples 'should have reader',
      :commands,
      -> { an_instance_of Array }

    it { expect(instance.commands).to contain_exactly(*expected) }
  end

  describe '#publish' do
    let(:book) do
      Spec::Book.new(title: 'The Dispossessed', author: 'Ursula K. Le Guin')
    end
    let(:publisher) { 'Harper & Row' }

    it { expect(instance).to respond_to(:publish).with(1).argument }

    it { expect(instance.publish(publisher)).to be_a Spec::PublishBookCommand }

    it { expect(instance.publish(publisher).publisher).to be == publisher }

    it 'should publish the book' do
      command = instance.publish(publisher)

      command.call(book)

      expect(book.publisher).to be == publisher
    end
  end

  describe '#save' do
    let(:book) do
      Spec::Book.new(
        title:  'The Left Hand of Darkness',
        author: 'Ursula K. Le Guin'
      )
    end

    it { expect(instance).to respond_to(:save).with(0).arguments }

    it { expect(instance.save).to be_a instance::Save }

    it 'should save the book' do
      command = instance.save

      expect { command.call(book) }.to change(books_collection, :count).by(1)

      expect(books_collection).to include book
    end
  end

  describe '#validate' do
    it { expect(instance).to respond_to(:validate).with(1).arguments }

    it { expect(instance.validate).to be_a Cuprum::Command }

    describe 'with an invalid book' do
      let(:book) { Spec::Book.new title: 'The Tombs of Atuan' }

      it 'should validate the book' do
        command = instance.validate
        result  = command.call(book)
        error   = result.error

        expect(result.success?).to be false

        expect(error).to be_a Spec::ValidationError
        expect(error.errors).to include "author can't be blank"
      end
    end

    describe 'with a valid book' do
      let(:book) do
        Spec::Book.new title: 'The Farthest Shore', author: 'Ursula K. Le Guin'
      end

      it 'should validate the book' do
        command = instance.validate
        result  = command.call(book)

        expect(result.success?).to be true
        expect(result.error).to be nil
      end
    end
  end
end
