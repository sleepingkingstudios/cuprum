# frozen_string_literal: true

require 'cuprum/rspec/be_a_result'

require 'support/commands/publish_book'
require 'support/models/book'

RSpec.describe Spec::Commands::PublishBook do
  subject(:command) { described_class.new(publisher: publisher) }

  let(:publisher) { 'Baen' }

  describe '#call' do
    let(:book) do
      Spec::Models::Book.new(
        attributes: {
          title:  'On Basilisk Station',
          author: 'David Weber'
        }
      )
    end
    let(:result) { command.call(book: book) }

    it { expect(result).to be_a_passing_result }

    it { expect(result.value).to be book }

    it { expect(result.value.publisher).to be == publisher }
  end
end
