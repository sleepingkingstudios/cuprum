# frozen_string_literal: true

require 'cuprum/rspec/be_a_result'

require 'support/commands/save_book_to_collection'
require 'support/models/book'

RSpec.describe Spec::Commands::SaveBookToCollection do
  subject(:command) { described_class.new(collection: collection) }

  let(:collection) { [] }

  describe '#call' do
    let(:book) do
      Spec::Models::Book.new(
        attributes: {
          title:  'Oath of Swords',
          author: 'David Weber'
        }
      )
    end
    let(:result) { command.call(book: book) }

    it { expect(result).to be_a_passing_result }

    it 'should add the book to the collection' do
      expect { command.call(book: book) }
        .to change(collection, :to_a)
        .to include(book)
    end
  end

  describe '#collection' do
    include_examples 'should have reader', :collection, -> { collection }
  end
end
