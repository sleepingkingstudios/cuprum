# frozen_string_literal: true

require 'cuprum/rspec/be_a_result'

require 'support/commands/build_book'
require 'support/models/book'

RSpec.describe Spec::Commands::BuildBook do
  subject(:command) { described_class.new }

  describe '#call' do
    describe 'with an empty hash' do
      let(:attributes) { {} }
      let(:result)     { command.call(attributes: attributes) }

      it { expect(result).to be_a_passing_result }

      it 'should return the book' do
        expect(result.value).to be_a(Spec::Models::Book).and(
          have_attributes(attributes)
        )
      end
    end

    describe 'with valid attributes' do
      let(:attributes) { { title: 'Gideon the Ninth', author: 'Tammsyn Muir' } }
      let(:result)     { command.call(attributes: attributes) }

      it { expect(result).to be_a_passing_result }

      it 'should return the book' do
        expect(result.value).to be_a(Spec::Models::Book).and(
          have_attributes(attributes)
        )
      end
    end
  end

  describe '#model_class' do
    include_examples 'should have reader',
      :model_class,
      -> { Spec::Models::Book }
  end
end
