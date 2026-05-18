# frozen_string_literal: true

require 'cuprum/error'

RSpec.describe Cuprum::Error do
  subject(:error) do
    described_class.new(message:, type:, **properties)
  end

  let(:message)    { nil }
  let(:properties) { {} }
  let(:type)       { nil }

  define_method :tools do
    SleepingKingStudios::Tools::Toolbelt.instance
  end

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
        let(:other) { described_class.new(message:) }

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

        let(:other) { Spec::Error.new(message:) }

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
        let(:other) { described_class.new(type:) }

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

        let(:other) { Spec::Error.new(type:) }

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
        let(:other) { described_class.new(message:) }

        it { expect(error == other).to be false }
      end

      describe 'with an Error with non-matching type' do
        let(:other) { described_class.new(type: 'spec.non_matching_type') }

        it { expect(error == other).to be false }
      end

      describe 'with an Error with matching type' do
        let(:other) { described_class.new(type:) }

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
            message:,
            type:,
            color:   'red',
            shape:   'möbius strip'
          )
        end

        it { expect(error == other).to be true }
      end
    end

    describe 'when the Error subclass defines custom comparable properties' do
      include_context 'when there is an error subclass'

      subject(:error) { Spec::Error.new(message:, **properties) }

      before(:example) do
        Spec::Error.define_method(:color) do
          @comparable_properties[:color] # rubocop:disable RSpec/InstanceVariable
        end

        Spec::Error.define_method(:comparable_properties) do
          { color: }
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
    deferred_context 'when there are custom error messages defined' do
      let(:messages) do
        {
          spec: {
            custom_error:  'This is a custom error message',
            example_error: 'This is an example error message',
            locale_error:  'Locale not found with key %<locale>s'
          }
        }
      end
      let(:registry) do
        SleepingKingStudios::Tools::Messages::Registry
          .new
          .register(hash: messages, scope: 'spec')
      end

      before(:example) do
        allow(tools.messages).to receive(:registry).and_return(registry)
      end
    end

    include_examples 'should have reader', :message, nil

    context 'when initialized with no arguments' do
      subject(:error) { described_class.new }

      it { expect(error.message).to be nil }
    end

    context 'when initialized with a message' do
      let(:message) { 'Something went wrong.' }

      it { expect(error.message).to be == message }
    end

    context 'when initialized with a type' do
      let(:type) { 'spec.custom_error' }

      it { expect(error.message).to be nil }

      wrap_deferred 'when there are custom error messages defined' do
        let(:expected) { 'This is a custom error message' }

        it { expect(error.message).to be == expected }

        context 'when initialized with a message' do
          let(:message) { 'Something went wrong.' }

          it { expect(error.message).to be == message }
        end

        context 'when the defined message requires parameters' do
          let(:type) { 'spec.locale_error' }
          let(:expected) do
            'Message missing parameters: spec.locale_error key<locale> not ' \
              'found'
          end

          it { expect(error.message).to be == expected }

          describe 'with the required parameters' do # rubocop:disable RSpec/NestedGroups
            let(:properties) { super().merge(locale: 'en') }
            let(:expected)   { 'Locale not found with key en' }

            it { expect(error.message).to be == expected }
          end
        end
      end
    end

    context 'when there is an error subclass' do
      let(:described_class) { Spec::ExampleError }

      example_class 'Spec::ExampleError', described_class do |klass|
        klass.const_set :TYPE, 'spec.example_error'
      end

      it { expect(error.message).to be nil }

      context 'when the subclass defines :MESSAGE' do
        let(:message_template) do
          'This is a static error message'
        end
        let(:expected) { message_template }

        before(:example) do
          Spec::ExampleError.const_set(:MESSAGE, message_template)
        end

        it { expect(error.message).to be == expected }

        context 'when initialized with a message' do
          let(:message) { 'Something went wrong.' }

          it { expect(error.message).to be == message }
        end

        wrap_deferred 'when there are custom error messages defined' do
          let(:expected) { 'This is an example error message' }

          it { expect(error.message).to be == expected }
        end

        context 'when the message template takes parameters' do
          let(:message_template) do
            'Locale not found with key %<locale>s'
          end
          let(:expected) do
            'Message missing parameters: spec.example_error key<locale> not ' \
              'found'
          end

          it { expect(error.message).to be == expected }

          describe 'with the required parameters' do # rubocop:disable RSpec/NestedGroups
            let(:properties) { super().merge(locale: 'en') }
            let(:expected)   { 'Locale not found with key en' }

            it { expect(error.message).to be == expected }
          end
        end
      end

      wrap_deferred 'when there are custom error messages defined' do
        let(:expected) { 'This is an example error message' }

        it { expect(error.message).to be == expected }

        context 'when initialized with a message' do
          let(:message) { 'Something went wrong.' }

          it { expect(error.message).to be == message }
        end

        context 'when initialized with a type' do
          let(:type)     { 'spec.custom_error' }
          let(:expected) { 'This is a custom error message' }

          it { expect(error.message).to be == expected }
        end

        context 'when the defined message requires parameters' do
          let(:described_class) { Spec::LocaleError }
          let(:expected) do
            'Message missing parameters: spec.locale_error key<locale> not ' \
              'found'
          end

          example_class 'Spec::LocaleError', described_class do |klass|
            klass.const_set :TYPE, 'spec.locale_error'
          end

          it { expect(error.message).to be == expected }

          describe 'with the required parameters' do # rubocop:disable RSpec/NestedGroups
            let(:properties) { super().merge(locale: 'en') }
            let(:expected)   { 'Locale not found with key en' }

            it { expect(error.message).to be == expected }
          end
        end
      end
    end
  end

  describe '#type' do
    include_examples 'should define reader', :type, -> { described_class::TYPE }

    context 'when initialized with a type' do
      let(:type) { 'spec.custom_error' }

      it { expect(error.type).to be == type }
    end

    context 'when there is an error subclass' do
      let(:described_class) { Spec::ExampleError }

      example_class 'Spec::ExampleError', described_class do |klass|
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
