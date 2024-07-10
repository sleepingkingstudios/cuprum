# frozen_string_literal: true

require 'cuprum/errors/multiple_errors'

RSpec.describe Cuprum::Errors::MultipleErrors do
  subject(:error) { described_class.new(**constructor_options) }

  shared_context 'when initialized with errors: Array of errors' do
    let(:errors) do
      [
        Cuprum::Error.new(message: 'First error'),
        Cuprum::Error.new(message: 'Second error'),
        Cuprum::Error.new(message: 'Third error')
      ]
    end
  end

  let(:errors)              { [] }
  let(:constructor_options) { { errors: } }

  describe '::TYPE' do
    include_examples 'should define immutable constant',
      :TYPE,
      'cuprum.errors.multiple_errors'
  end

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:errors, :message)
    end
  end

  describe '#as_json' do
    let(:expected) do
      {
        'data'    => {
          'errors' => errors.map(&:as_json)
        },
        'message' => error.message,
        'type'    => error.type
      }
    end

    include_examples 'should have reader', :as_json, -> { be == expected }

    wrap_context 'when initialized with errors: Array of errors' do
      it { expect(error.errors).to be == errors }
    end

    context 'when initialized with errors: a sparse Array' do
      let(:errors) do
        [
          Cuprum::Error.new(message: 'First error'),
          nil,
          Cuprum::Error.new(message: 'Second error'),
          nil,
          Cuprum::Error.new(message: 'Third error')
        ]
      end

      it { expect(error.errors).to be == errors }
    end
  end

  describe '#errors' do
    include_examples 'should define reader', :errors, []

    wrap_context 'when initialized with errors: Array of errors' do
      it { expect(error.errors).to be == errors }
    end
  end

  describe '#message' do
    let(:expected) { 'the command encountered one or more errors' }

    include_examples 'should define reader', :message, -> { expected }

    context 'when initialized with message: value' do
      let(:message)             { 'Something went wrong' }
      let(:constructor_options) { super().merge(message:) }

      it { expect(error.message).to be == message }
    end
  end

  describe '#type' do
    include_examples 'should define reader', :type, -> { described_class::TYPE }
  end
end
