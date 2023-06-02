# frozen_string_literal: true

require 'cuprum/command'
require 'cuprum/command_factory'
require 'cuprum/rspec/be_a_result'

require 'support/command_factories/books_factory'
require 'support/models/book'

RSpec.describe Spec::CommandFactories::BooksFactory do
  include Cuprum::RSpec::Matchers

  subject(:instance) { described_class.new(books: books_collection) }

  let(:books_collection) { [] }

  describe '::Build' do
    it { expect(instance::Build).to be Spec::Commands::BuildBook }
  end

  describe '::Save' do
    it { expect(instance::Save).to be_a Class }

    it { expect(instance::Save).to be < Spec::Commands::SaveBookToCollection }
  end

  describe '#build' do
    let(:attributes) do
      { title: 'A Wizard of Earthsea', author: 'Ursula K. Le Guin' }
    end

    it { expect(instance).to respond_to(:build).with(0).arguments }

    it { expect(instance.build).to be_a Spec::Commands::BuildBook }

    it 'should build a book', :aggregate_failures do
      command = instance.build
      result  = command.call(attributes: attributes)
      book    = result.value

      expect(book).to be_a Spec::Models::Book
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

    it { expect(instance.commands).to match_array(expected) }
  end

  describe '#publish' do
    let(:book) do
      Spec::Models::Book.new(
        attributes: {
          title:  'The Dispossessed',
          author: 'Ursula K. Le Guin'
        }
      )
    end
    let(:publisher) { 'Harper & Row' }

    it { expect(instance).to respond_to(:publish).with(1).argument }

    it 'should return a command' do
      expect(instance.publish(publisher)).to be_a Spec::Commands::PublishBook
    end

    it { expect(instance.publish(publisher).publisher).to be == publisher }

    it 'should publish the book' do
      command = instance.publish(publisher)

      command.call(book: book)

      expect(book.publisher).to be == publisher
    end
  end

  describe '#save' do
    let(:book) do
      Spec::Models::Book.new(
        attributes: {
          title:  'The Left Hand of Darkness',
          author: 'Ursula K. Le Guin'
        }
      )
    end

    it { expect(instance).to respond_to(:save).with(0).arguments }

    it { expect(instance.save).to be_a instance::Save }

    it 'should save the book', :aggregate_failures do
      command = instance.save

      expect { command.call(book: book) }
        .to change(books_collection, :count)
        .by(1)

      expect(books_collection).to include book
    end
  end

  describe '#validate' do
    it { expect(instance).to respond_to(:validate).with(1).arguments }

    it { expect(instance.validate).to be_a Cuprum::Command }

    describe 'with an invalid book' do
      let(:command) { instance.validate }
      let(:book) do
        Spec::Models::Book.new(
          attributes: { title: 'The Tombs of Atuan' }
        )
      end
      let(:result) { command.call(book) }
      let(:expected_error) do
        Spec::Errors::NotValid.new(
          errors:      [['author', "can't be blank"]],
          model_class: Spec::Models::Book
        )
      end

      it { expect(result).to be_a_failing_result.with_error(expected_error) }
    end

    describe 'with a valid book' do
      let(:book) do
        Spec::Models::Book.new(
          attributes: {
            title:  'The Farthest Shore',
            author: 'Ursula K. Le Guin'
          }
        )
      end

      it 'should validate the book', :aggregate_failures do
        command = instance.validate
        result  = command.call(book)

        expect(result.success?).to be true
        expect(result.error).to be nil
      end
    end
  end
end
