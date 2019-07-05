# frozen_string_literal: true

require 'cuprum/errors/operation_not_called'

RSpec.describe Cuprum::Errors::OperationNotCalled do
  subject(:error) { described_class.new(operation: operation) }

  let(:operation) { Spec::ExampleOperation.new }

  example_class 'Spec::ExampleOperation', Cuprum::Operation

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:operation)
    end

    describe 'with no arguments' do
      let(:error_message) { 'missing keyword: operation' }

      it 'should raise an error' do
        expect { described_class.new }
          .to raise_error ArgumentError, error_message
      end
    end
  end

  describe '#message' do
    let(:expected_message) do
      'Spec::ExampleOperation was not called and does not have a result'
    end

    include_examples 'should have reader',
      :message,
      -> { be == expected_message }

    context 'when initialized with a nil operation' do
      let(:operation) { nil }
      let(:expected_message) do
        'operation was not called and does not have a result'
      end

      it { expect(error.message).to be == expected_message }
    end
  end

  describe '#operation' do
    include_examples 'should have reader', :operation, -> { operation }
  end
end
