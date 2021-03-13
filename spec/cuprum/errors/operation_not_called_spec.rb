# frozen_string_literal: true

require 'cuprum/errors/operation_not_called'

RSpec.describe Cuprum::Errors::OperationNotCalled do
  subject(:error) { described_class.new(operation: operation) }

  let(:operation) { Spec::ExampleOperation.new }

  example_class 'Spec::ExampleOperation', Cuprum::Operation

  describe '::TYPE' do
    include_examples 'should define immutable constant',
      :TYPE,
      'cuprum.errors.operation_not_called'
  end

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:operation)
    end

    describe 'with no arguments' do
      let(:error_message) do
        # :nocov:
        if RUBY_VERSION >= '2.7.0'
          'missing keyword: :operation'
        else
          'missing keyword: operation'
        end
        # :nocov:
      end

      it 'should raise an error' do
        expect { described_class.new }
          .to raise_error ArgumentError, error_message
      end
    end
  end

  describe '#==' do
    describe 'with nil' do
      # rubocop:disable Style/NilComparison
      it { expect(error == nil).to be false }
      # rubocop:enable Style/NilComparison
    end

    describe 'with an Object' do
      it { expect(error == Object.new.freeze).to be false }
    end

    describe 'with a non-matching Error with no message' do
      let(:other) { Cuprum::Error.new }

      it { expect(error == other).to be false }
    end

    describe 'with a non-matching Error with non-matching message' do
      let(:other) { Cuprum::Error.new(message: 'An error occurred.') }

      it { expect(error == other).to be false }
    end

    describe 'with a non-matching Error with matching message' do
      let(:other) { Cuprum::Error.new(message: error.message) }

      it { expect(error == other).to be false }
    end

    describe 'with a matching Error with non-matching operation' do
      let(:other) { described_class.new(operation: Cuprum::Operation.new) }

      it { expect(error == other).to be false }
    end

    describe 'with a matching Error with operation of same class' do
      let(:other) { described_class.new(operation: Spec::ExampleOperation.new) }

      it { expect(error == other).to be false }
    end

    describe 'with a matching Error with matching operation' do
      let(:other) { described_class.new(operation: operation) }

      it { expect(error == other).to be true }
    end
  end

  describe '#as_json' do
    let(:expected) do
      {
        'data'    => {
          'class_name' => 'Spec::ExampleOperation'
        },
        'message' => error.message,
        'type'    => error.type
      }
    end

    include_examples 'should define reader', :as_json, -> { be == expected }

    context 'when initialized with a nil operation' do
      let(:operation) { nil }
      let(:expected)  { super().merge('data' => {}) }

      it { expect(error.as_json).to be == expected }
    end
  end

  describe '#message' do
    let(:expected_message) do
      'Spec::ExampleOperation was not called and does not have a result'
    end

    include_examples 'should define reader',
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
    include_examples 'should define reader', :operation, -> { operation }
  end

  describe '#type' do
    include_examples 'should define reader', :type, -> { described_class::TYPE }
  end
end
