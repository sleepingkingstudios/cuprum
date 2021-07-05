# frozen_string_literal: true

require 'cuprum/error'

RSpec.describe Cuprum::Error do
  subject(:error) do
    described_class.new(message: message, type: type, **properties)
  end

  let(:message)    { nil }
  let(:properties) { {} }
  let(:type)       { nil }

  describe '::TYPE' do
    include_examples 'should define immutable constant',
      :TYPE,
      'cuprum.error'
  end

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

    describe 'with an error with non-matching type' do
      let(:other) { described_class.new(type: 'spec.non_matching_type') }

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

    describe 'with an Error subclass with non-matching type' do
      include_context 'when there is an error subclass'

      let(:other) { Spec::Error.new(type: 'spec.non_matching_type') }

      it { expect(error == other).to be false }
    end

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

    context 'when initialized with a type' do
      let(:type) { 'spec.custom_error' }

      describe 'with nil' do
        # rubocop:disable Style/NilComparison
        it { expect(error == nil).to be false }
        # rubocop:enable Style/NilComparison
      end

      describe 'with an Object' do
        it { expect(error == Object.new.freeze).to be false }
      end

      describe 'with an Error with no type' do
        let(:other) { described_class.new }

        it { expect(error == other).to be false }
      end

      describe 'with an Error with non-matching type' do
        let(:other) { described_class.new(type: 'spec.non_matching_type') }

        it { expect(error == other).to be false }
      end

      describe 'with an Error with matching type' do
        let(:other) { described_class.new(type: type) }

        it { expect(error == other).to be true }
      end

      describe 'with an Error subclass with no type' do
        include_context 'when there is an error subclass'

        let(:other) { Spec::Error.new }

        it { expect(error == other).to be false }
      end

      describe 'with an Error subclass with non-matching type' do
        include_context 'when there is an error subclass'

        let(:other) { Spec::Error.new(type: 'spec.non_matching_type') }

        it { expect(error == other).to be false }
      end

      describe 'with an Error subclass with matching type' do
        include_context 'when there is an error subclass'

        let(:other) { Spec::Error.new(type: type) }

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

    context 'when initialized with custom values' do
      let(:message)    { 'Something went wrong.' }
      let(:properties) { { color: 'red', shape: 'möbius strip' } }
      let(:type)       { 'spec.custom_error' }

      describe 'with nil' do
        # rubocop:disable Style/NilComparison
        it { expect(error == nil).to be false }
        # rubocop:enable Style/NilComparison
      end

      describe 'with an Object' do
        it { expect(error == Object.new.freeze).to be false }
      end

      describe 'with an Error with no values' do
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

      describe 'with an Error with non-matching type' do
        let(:other) { described_class.new(type: 'spec.non_matching_type') }

        it { expect(error == other).to be false }
      end

      describe 'with an Error with matching type' do
        let(:other) { described_class.new(type: type) }

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

      describe 'with an Error with matching values' do
        let(:other) do
          described_class.new(
            message: message,
            type:    type,
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
  end

  describe '#as_json' do
    let(:expected) do
      {
        'data'    => {},
        'message' => error.message,
        'type'    => error.type
      }
    end

    it { expect(error).to respond_to(:as_json).with(0).arguments }

    it { expect(error.as_json).to be == expected }

    context 'when initialized with a message' do
      let(:message) { 'Something went wrong.' }

      it { expect(error.as_json).to be == expected }
    end

    context 'when initialized with a type' do
      let(:type) { 'spec.custom_error' }

      it { expect(error.as_json).to be == expected }
    end
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

  describe '#type' do
    include_examples 'should define reader', :type, -> { described_class::TYPE }

    context 'when initialized with a type' do
      let(:type) { 'spec.custom_error' }

      it { expect(error.type).to be == type }
    end

    context 'when there is an error subclass' do
      example_class 'Spec::Error', described_class do |klass|
        klass.const_set :TYPE, 'spec.example_error'
      end

      it { expect(error.type).to be == described_class::TYPE }

      context 'when initialized with a type' do
        let(:type) { 'spec.custom_error' }

        it { expect(error.type).to be == type }
      end
    end
  end
end
