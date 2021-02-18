# frozen_string_literal: true

require 'cuprum/error'

RSpec.describe Cuprum::Error do
  subject(:error) { described_class.new(message: message, **properties) }

  let(:message)    { nil }
  let(:properties) { {} }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:message)
        .and_any_keywords
    end
  end

  describe '#==' do
    shared_context 'when there is an error subclass' do
      example_class 'Spec::Error', described_class
    end

    describe 'with nil' do
      # rubocop:disable Style/NilComparison
      it { expect(error == nil).to be false }
      # rubocop:enable Style/NilComparison
    end

    describe 'with an Object' do
      it { expect(error == Object.new.freeze).to be false }
    end

    describe 'with an error with no message' do
      let(:other) { described_class.new }

      it { expect(error == other).to be true }
    end

    describe 'with an error with non-matching message' do
      let(:other) { described_class.new(message: 'An error occurred.') }

      it { expect(error == other).to be false }
    end

    describe 'with an error with non-matching properties' do
      let(:other) { described_class.new(color: 'red') }

      it { expect(error == other).to be false }
    end

    describe 'with an Error subclass with no message' do
      include_context 'when there is an error subclass'

      let(:other) { Spec::Error.new }

      it { expect(error == other).to be false }
    end

    describe 'with an Error subclass with non-matching message' do
      include_context 'when there is an error subclass'

      let(:other) { Spec::Error.new(message: 'An error occurred.') }

      it { expect(error == other).to be false }
    end

    describe 'with an Error subclass with non-matching properties' do
      include_context 'when there is an error subclass'

      let(:other) { Spec::Error.new(color: 'red') }

      it { expect(error == other).to be false }
    end

    # rubocop:disable RSpec/NestedGroups
    context 'when initialized with a message' do
      let(:message) { 'Something went wrong.' }

      describe 'with nil' do
        # rubocop:disable Style/NilComparison
        it { expect(error == nil).to be false }
        # rubocop:enable Style/NilComparison
      end

      describe 'with an Object' do
        it { expect(error == Object.new.freeze).to be false }
      end

      describe 'with an Error with no message' do
        let(:other) { described_class.new }

        it { expect(error == other).to be false }
      end

      describe 'with an Error with non-matching message' do
        let(:other) { described_class.new(message: 'An error occurred.') }

        it { expect(error == other).to be false }
      end

      describe 'with an Error with matching message' do
        let(:other) { described_class.new(message: message) }

        it { expect(error == other).to be true }
      end

      describe 'with an Error subclass with no message' do
        include_context 'when there is an error subclass'

        let(:other) { Spec::Error.new }

        it { expect(error == other).to be false }
      end

      describe 'with an Error subclass with non-matching message' do
        include_context 'when there is an error subclass'

        let(:other) { Spec::Error.new(message: 'An error occurred.') }

        it { expect(error == other).to be false }
      end

      describe 'with an Error subclass with matching message' do
        include_context 'when there is an error subclass'

        let(:other) { Spec::Error.new(message: message) }

        it { expect(error == other).to be false }
      end
    end

    context 'when initialized with properties' do
      let(:properties) { { color: 'red', shape: 'möbius strip' } }

      describe 'with nil' do
        # rubocop:disable Style/NilComparison
        it { expect(error == nil).to be false }
        # rubocop:enable Style/NilComparison
      end

      describe 'with an Object' do
        it { expect(error == Object.new.freeze).to be false }
      end

      describe 'with an Error with non-matching message' do
        let(:other) { described_class.new(message: 'An error occurred.') }

        it { expect(error == other).to be false }
      end

      describe 'with an Error with no properties' do
        let(:other) { described_class.new }

        it { expect(error == other).to be false }
      end

      describe 'with an Error with non-matching properties' do
        let(:other) { described_class.new(color: 'blue', shape: 'torus') }

        it { expect(error == other).to be false }
      end

      describe 'with an Error with partially-matching properties' do
        let(:other) { described_class.new(color: 'red', shape: 'torus') }

        it { expect(error == other).to be false }
      end

      describe 'with an Error with matching properties' do
        let(:other) { described_class.new(color: 'red', shape: 'möbius strip') }

        it { expect(error == other).to be true }
      end
    end

    context 'when initialized with properties and a message' do
      let(:message)    { 'Something went wrong.' }
      let(:properties) { { color: 'red', shape: 'möbius strip' } }

      describe 'with nil' do
        # rubocop:disable Style/NilComparison
        it { expect(error == nil).to be false }
        # rubocop:enable Style/NilComparison
      end

      describe 'with an Object' do
        it { expect(error == Object.new.freeze).to be false }
      end

      describe 'with an Error with no message or properties' do
        let(:other) { described_class.new }

        it { expect(error == other).to be false }
      end

      describe 'with an Error with non-matching message' do
        let(:other) { described_class.new(message: 'An error occurred.') }

        it { expect(error == other).to be false }
      end

      describe 'with an Error with matching message' do
        let(:other) { described_class.new(message: message) }

        it { expect(error == other).to be false }
      end

      describe 'with an Error with non-matching properties' do
        let(:other) { described_class.new(color: 'blue', shape: 'torus') }

        it { expect(error == other).to be false }
      end

      describe 'with an Error with partially-matching properties' do
        let(:other) { described_class.new(color: 'red', shape: 'torus') }

        it { expect(error == other).to be false }
      end

      describe 'with an Error with matching properties' do
        let(:other) { described_class.new(color: 'red', shape: 'möbius strip') }

        it { expect(error == other).to be false }
      end

      describe 'with an Error with matching properties and message' do
        let(:other) do
          described_class.new(
            message: message,
            color:   'red',
            shape:   'möbius strip'
          )
        end

        it { expect(error == other).to be true }
      end
    end

    describe 'when the Error subclass defines custom comparable properties' do
      include_context 'when there is an error subclass'

      subject(:error) { Spec::Error.new(message: message, **properties) }

      before(:example) do
        Spec::Error.define_method(:color) do
          @comparable_properties[:color] # rubocop:disable RSpec/InstanceVariable
        end

        Spec::Error.define_method(:comparable_properties) do
          { color: color }
        end
      end

      describe 'with an error with no message or properties' do
        let(:other) { Spec::Error.new }

        it { expect(error == other).to be true }
      end

      describe 'with an error with non-matching message' do
        let(:other) { Spec::Error.new(message: 'An error occurred.') }

        it { expect(error == other).to be true }
      end

      describe 'with an error with non-matching properties' do
        let(:other) { Spec::Error.new(color: 'blue') }

        it { expect(error == other).to be false }
      end

      describe 'with an error with matching properties' do
        let(:other) { Spec::Error.new(shape: 'torus') }

        it { expect(error == other).to be true }
      end

      context 'when initialized with properties' do
        let(:properties) { { color: 'red', shape: 'möbius strip' } }

        describe 'with an error with no properties' do
          let(:other) { Spec::Error.new }

          it { expect(error == other).to be false }
        end

        describe 'with an error with non-matching properties' do
          let(:other) { Spec::Error.new(color: 'blue', shape: 'möbius strip') }

          it { expect(error == other).to be false }
        end

        describe 'with an error with matching properties' do
          let(:other) { Spec::Error.new(color: 'red', shape: 'torus') }

          it { expect(error == other).to be true }
        end
      end
    end
    # rubocop:enable RSpec/NestedGroups
  end

  describe '#message' do
    include_examples 'should have reader', :message, nil

    context 'when initialized with no arguments' do
      subject(:error) { described_class.new }

      it { expect(error.message).to be nil }
    end

    context 'when initialized with a message' do
      let(:message) { 'Something went wrong.' }

      it { expect(error.message).to be == message }
    end
  end
end
