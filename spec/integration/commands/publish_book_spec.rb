# frozen_string_literal: true

require 'cuprum/rspec/be_a_result'
require 'cuprum/rspec/be_callable'

require 'support/commands/publish_book'
require 'support/models/book'

RSpec.describe Spec::Commands::PublishBook do
  include Cuprum::RSpec::Matchers

  subject(:command) { described_class.new(publisher:) }

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
    let(:result) { command.call(book:) }

    it 'should define the method' do
      expect(command)
        .to be_callable
        .with(0).arguments
        .and_keywords(:book)
    end

    it { expect(result).to be_a_passing_result }

    it { expect(result.value).to be book }

    it { expect(result.value.publisher).to be == publisher }
  end
end
