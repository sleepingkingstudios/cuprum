# frozen_string_literal: true

require 'cuprum/rspec/be_a_result'
require 'cuprum/rspec/be_callable'

require 'support/commands/save_book_to_collection'
require 'support/models/book'

RSpec.describe Spec::Commands::SaveBookToCollection do
  include Cuprum::RSpec::Matchers

  subject(:command) { described_class.new(collection:) }

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
    let(:result) { command.call(book:) }

    it 'should define the method' do
      expect(command)
        .to be_callable
        .with(0).arguments
        .and_keywords(:book)
    end

    it { expect(result).to be_a_passing_result }

    it 'should add the book to the collection' do
      expect { command.call(book:) }
        .to change(collection, :to_a)
        .to include(book)
    end
  end

  describe '#collection' do
    include_examples 'should have reader', :collection, -> { collection }
  end
end
