require 'cuprum/built_in/null_operation'
require 'cuprum/result'

RSpec.describe Cuprum::Result do
  shared_context 'when the result has a value' do
    let(:value) { 'returned value'.freeze }

    before(:example) { instance.value = value }
  end # shared_context

  shared_context 'when the result has many errors' do
    let(:errors) { ['errors.messages.unknown'] }

    before(:example) do
      instance.errors = errors
    end # before example
  end # shared_context

  shared_context 'when the result status is set to failure' do
    before(:example) { instance.failure! }
  end # shared_context

  shared_context 'when the result status is set to success' do
    before(:example) { instance.success! }
  end # shared_context

  shared_context 'when the result has many errors and success status' do
    include_context 'when the result has many errors'
    include_context 'when the result status is set to success'
  end # shared_context

  shared_context 'when the result is halted' do
    before(:example) { instance.halt! }
  end # shared_context

  subject(:instance) { described_class.new }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class).
        to be_constructible.
        with(0..1).arguments.
        and_keywords(:errors)
    end # it

    describe 'with an errors object' do
      let(:errors)   { ['errors.messages.unknown'] }
      let(:instance) { described_class.new(:errors => errors) }

      it { expect(instance.errors).to be errors }

      it { expect(instance.failure?).to be true }
    end # describe

    describe 'with a value' do
      let(:value)    { 'returned value'.freeze }
      let(:instance) { described_class.new(value) }

      it { expect(instance.value).to be value }

      it { expect(instance.success?).to be true }
    end # describe

    describe 'with a value and an errors object' do
      let(:value)    { 'returned value'.freeze }
      let(:errors)   { ['errors.messages.unknown'] }
      let(:instance) { described_class.new(value, :errors => errors) }

      it { expect(instance.value).to be value }

      it { expect(instance.errors).to be errors }

      it { expect(instance.failure?).to be true }
    end # describe
  end # describe

  describe '#==' do
    describe 'with nil' do
      # rubocop:disable Style/NilComparison
      it { expect(instance == nil).to be false }
      # rubocop:enable Style/NilComparison
    end # describe

    describe 'with an empty result' do
      let(:other) { described_class.new }

      it { expect(instance == other).to be true }
    end # describe

    describe 'with a result with a value' do
      let(:other) { described_class.new('other value'.freeze) }

      it { expect(instance == other).to be false }
    end # describe

    describe 'with a result with many errors' do
      let(:other) do
        described_class.new.
          tap { |result| result.errors = ['errors.messages.unknown'] }
      end # let

      it { expect(instance == other).to be false }
    end # describe

    describe 'with a result with many errors and success status' do
      let(:other) do
        described_class.new.
          tap { |result| result.errors = ['errors.messages.unknown'] }.
          tap(&:success!)
      end # let

      it { expect(instance == other).to be false }
    end # describe

    describe 'with a result with status set to failure' do
      let(:other) { described_class.new.tap(&:failure!) }

      it { expect(instance == other).to be false }
    end # describe

    describe 'with a result with status set to success' do
      let(:other) { described_class.new.tap(&:success!) }

      it { expect(instance == other).to be true }
    end # describe

    describe 'with a halted result' do
      let(:other) { described_class.new.tap(&:halt!) }

      it { expect(instance == other).to be false }
    end # describe

    describe 'with an uncalled operation' do
      let(:other) { Cuprum::BuiltIn::NullOperation.new }

      it { expect(instance == other).to be false }
    end # describe

    describe 'with a called operation' do
      let(:other) { Cuprum::BuiltIn::NullOperation.new.call }

      it { expect(instance == other).to be true }
    end # describe

    describe 'with a called operation with a value' do
      let(:other) do
        Cuprum::Operation.new do
          'other value'.freeze
        end.call
      end # let

      it { expect(instance == other).to be false }
    end # describe

    describe 'with a called operation with many errors' do
      let(:other) do
        Cuprum::Operation.new do
          errors << 'errors.messages.unknown'

          nil
        end.call
      end # let

      it { expect(instance == other).to be false }
    end # describe

    describe 'with a called operation with many errors and success status' do
      let(:other) do
        Cuprum::Operation.new do
          errors << 'errors.messages.unknown'

          success!

          nil
        end.call
      end # let

      it { expect(instance == other).to be false }
    end # describe

    describe 'with a called operation with status set to failure' do
      let(:other) do
        Cuprum::Operation.new do
          failure!

          nil
        end.call
      end # let

      it { expect(instance == other).to be false }
    end # describe

    describe 'with a called operation with status set to success' do
      let(:other) do
        Cuprum::Operation.new do
          success!

          nil
        end.call
      end # let

      it { expect(instance == other).to be true }
    end # describe

    describe 'with a called and halted operation' do
      let(:other) do
        Cuprum::Operation.new do
          halt!

          nil
        end.call
      end # let

      it { expect(instance == other).to be false }
    end # describe

    wrap_context 'when the result has a value' do
      describe 'with an empty result' do
        let(:other) { described_class.new }

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a result with a non-matching value' do
        let(:other) { described_class.new('other value'.freeze) }

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a result with a matching value' do
        let(:other) { described_class.new(value) }

        it { expect(instance == other).to be true }
      end # describe

      describe 'with a called operation with many errors' do
        let(:other) do
          Cuprum::Operation.new do
            errors << 'errors.messages.unknown'

            nil
          end.call
        end # let

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a called operation with many errors and success status' do
        let(:other) do
          Cuprum::Operation.new do
            errors << 'errors.messages.unknown'

            success!

            nil
          end.call
        end # let

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a called operation with status set to failure' do
        let(:other) do
          Cuprum::Operation.new do
            failure!

            nil
          end.call
        end # let

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a called operation with status set to success' do
        let(:other) do
          Cuprum::Operation.new do
            success!

            nil
          end.call
        end # let

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a called and halted operation' do
        let(:other) do
          Cuprum::Operation.new do
            halt!

            nil
          end.call
        end # let

        it { expect(instance == other).to be false }
      end # describe
    end # wrap_context

    wrap_context 'when the result has many errors' do
      describe 'with an empty result' do
        let(:other) { described_class.new }

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a result with a value' do
        let(:other) { described_class.new('other value'.freeze) }

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a result with non-matching errors' do
        let(:other) do
          described_class.new.
            tap { |result| result.errors = ['errors.messages.other'] }
        end # let

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a result with matching errors' do
        let(:other) do
          described_class.new.
            tap { |result| result.errors = ['errors.messages.unknown'] }
        end # let

        it { expect(instance == other).to be true }
      end # describe

      describe 'with a result with matching errors and success status' do
        let(:other) do
          described_class.new.
            tap { |result| result.errors = ['errors.messages.unknown'] }.
            tap(&:success!)
        end # let

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a result with status set to failure' do
        let(:other) { described_class.new.tap(&:failure!) }

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a result with status set to success' do
        let(:other) { described_class.new.tap(&:success!) }

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a halted result' do
        let(:other) { described_class.new.tap(&:halt!) }

        it { expect(instance == other).to be false }
      end # describe

      describe 'with an uncalled operation' do
        let(:other) { Cuprum::BuiltIn::NullOperation.new }

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a called operation' do
        let(:other) { Cuprum::BuiltIn::NullOperation.new.call }

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a called operation with a value' do
        let(:other) do
          Cuprum::Operation.new do
            'other value'.freeze
          end.call
        end # let

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a called operation with non-matching errors' do
        let(:other) do
          Cuprum::Operation.new do
            errors << 'errors.messages.other'

            nil
          end.call
        end # let

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a called operation with matching errors' do
        let(:other) do
          Cuprum::Operation.new do
            errors << 'errors.messages.unknown'

            nil
          end.call
        end # let

        it { expect(instance == other).to be true }
      end # describe

      describe 'with a called operation with matching errors and ' \
               'success status' do
        let(:other) do
          Cuprum::Operation.new do
            errors << 'errors.messages.unknown'

            success!

            nil
          end.call
        end # let

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a called operation with status set to failure' do
        let(:other) do
          Cuprum::Operation.new do
            failure!

            nil
          end.call
        end # let

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a called operation with status set to success' do
        let(:other) do
          Cuprum::Operation.new do
            success!

            nil
          end.call
        end # let

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a called and halted operation' do
        let(:other) do
          Cuprum::Operation.new do
            halt!

            nil
          end.call
        end # let

        it { expect(instance == other).to be false }
      end # describe
    end # wrap_context

    wrap_context 'when the result has many errors and success status' do
      describe 'with an empty result' do
        let(:other) { described_class.new }

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a result with a value' do
        let(:other) { described_class.new('other value'.freeze) }

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a result with non-matching errors' do
        let(:other) do
          described_class.new.
            tap { |result| result.errors = ['errors.messages.other'] }
        end # let

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a result with matching errors' do
        let(:other) do
          described_class.new.
            tap { |result| result.errors = ['errors.messages.unknown'] }
        end # let

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a result with matching errors and success status' do
        let(:other) do
          described_class.new.
            tap { |result| result.errors = ['errors.messages.unknown'] }.
            tap(&:success!)
        end # let

        it { expect(instance == other).to be true }
      end # describe

      describe 'with a result with status set to failure' do
        let(:other) { described_class.new.tap(&:failure!) }

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a result with status set to success' do
        let(:other) { described_class.new.tap(&:success!) }

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a halted result' do
        let(:other) { described_class.new.tap(&:halt!) }

        it { expect(instance == other).to be false }
      end # describe

      describe 'with an uncalled operation' do
        let(:other) { Cuprum::BuiltIn::NullOperation.new }

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a called operation' do
        let(:other) { Cuprum::BuiltIn::NullOperation.new.call }

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a called operation with a value' do
        let(:other) do
          Cuprum::Operation.new do
            'other value'.freeze
          end.call
        end # let

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a called operation with non-matching errors' do
        let(:other) do
          Cuprum::Operation.new do
            errors << 'errors.messages.other'

            nil
          end.call
        end # let

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a called operation with matching errors' do
        let(:other) do
          Cuprum::Operation.new do
            errors << 'errors.messages.unknown'

            nil
          end.call
        end # let

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a called operation with matching errors and ' \
               'success status' do
        let(:other) do
          Cuprum::Operation.new do
            errors << 'errors.messages.unknown'

            success!

            nil
          end.call
        end # let

        it { expect(instance == other).to be true }
      end # describe

      describe 'with a called operation with status set to failure' do
        let(:other) do
          Cuprum::Operation.new do
            failure!

            nil
          end.call
        end # let

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a called operation with status set to success' do
        let(:other) do
          Cuprum::Operation.new do
            success!

            nil
          end.call
        end # let

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a called and halted operation' do
        let(:other) do
          Cuprum::Operation.new do
            halt!

            nil
          end.call
        end # let

        it { expect(instance == other).to be false }
      end # describe
    end # context

    wrap_context 'when the result status is set to failure' do
      describe 'with an empty result' do
        let(:other) { described_class.new }

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a result with a value' do
        let(:other) { described_class.new('other value'.freeze) }

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a result with many errors' do
        let(:other) do
          described_class.new.
            tap { |result| result.errors = ['errors.messages.unknown'] }
        end # let

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a result with many errors and success status' do
        let(:other) do
          described_class.new.
            tap { |result| result.errors = ['errors.messages.unknown'] }.
            tap(&:success!)
        end # let

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a result with status set to failure' do
        let(:other) { described_class.new.tap(&:failure!) }

        it { expect(instance == other).to be true }
      end # describe

      describe 'with a result with status set to success' do
        let(:other) { described_class.new.tap(&:success!) }

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a halted result' do
        let(:other) { described_class.new.tap(&:halt!) }

        it { expect(instance == other).to be false }
      end # describe

      describe 'with an uncalled operation' do
        let(:other) { Cuprum::BuiltIn::NullOperation.new }

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a called operation' do
        let(:other) { Cuprum::BuiltIn::NullOperation.new.call }

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a called operation with a value' do
        let(:other) do
          Cuprum::Operation.new do
            'other value'.freeze
          end.call
        end # let

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a called operation with many errors' do
        let(:other) do
          Cuprum::Operation.new do
            errors << 'errors.messages.unknown'

            nil
          end.call
        end # let

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a called operation with many errors and success status' do
        let(:other) do
          Cuprum::Operation.new do
            errors << 'errors.messages.unknown'

            success!

            nil
          end.call
        end # let

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a called operation with status set to failure' do
        let(:other) do
          Cuprum::Operation.new do
            failure!

            nil
          end.call
        end # let

        it { expect(instance == other).to be true }
      end # describe

      describe 'with a called operation with status set to success' do
        let(:other) do
          Cuprum::Operation.new do
            success!

            nil
          end.call
        end # let

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a called and halted operation' do
        let(:other) do
          Cuprum::Operation.new do
            halt!

            nil
          end.call
        end # let

        it { expect(instance == other).to be false }
      end # describe
    end # wrap_context

    wrap_context 'when the result status is set to success' do
      describe 'with an empty result' do
        let(:other) { described_class.new }

        it { expect(instance == other).to be true }
      end # describe

      describe 'with a result with a value' do
        let(:other) { described_class.new('other value'.freeze) }

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a result with many errors' do
        let(:other) do
          described_class.new.
            tap { |result| result.errors = ['errors.messages.unknown'] }
        end # let

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a result with many errors and success status' do
        let(:other) do
          described_class.new.
            tap { |result| result.errors = ['errors.messages.unknown'] }.
            tap(&:success!)
        end # let

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a result with status set to failure' do
        let(:other) { described_class.new.tap(&:failure!) }

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a result with status set to success' do
        let(:other) { described_class.new.tap(&:success!) }

        it { expect(instance == other).to be true }
      end # describe

      describe 'with a halted result' do
        let(:other) { described_class.new.tap(&:halt!) }

        it { expect(instance == other).to be false }
      end # describe

      describe 'with an uncalled operation' do
        let(:other) { Cuprum::BuiltIn::NullOperation.new }

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a called operation' do
        let(:other) { Cuprum::BuiltIn::NullOperation.new.call }

        it { expect(instance == other).to be true }
      end # describe

      describe 'with a called operation with a value' do
        let(:other) do
          Cuprum::Operation.new do
            'other value'.freeze
          end.call
        end # let

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a called operation with many errors' do
        let(:other) do
          Cuprum::Operation.new do
            errors << 'errors.messages.unknown'

            nil
          end.call
        end # let

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a called operation with many errors and success status' do
        let(:other) do
          Cuprum::Operation.new do
            errors << 'errors.messages.unknown'

            success!

            nil
          end.call
        end # let

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a called operation with status set to failure' do
        let(:other) do
          Cuprum::Operation.new do
            failure!

            nil
          end.call
        end # let

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a called operation with status set to success' do
        let(:other) do
          Cuprum::Operation.new do
            success!

            nil
          end.call
        end # let

        it { expect(instance == other).to be true }
      end # describe

      describe 'with a called and halted operation' do
        let(:other) do
          Cuprum::Operation.new do
            halt!

            nil
          end.call
        end # let

        it { expect(instance == other).to be false }
      end # describe
    end # wrap_context

    wrap_context 'when the result is halted' do
      describe 'with an empty result' do
        let(:other) { described_class.new }

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a result with a value' do
        let(:other) { described_class.new('other value'.freeze) }

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a result with many errors' do
        let(:other) do
          described_class.new.
            tap { |result| result.errors = ['errors.messages.unknown'] }
        end # let

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a result with many errors and success status' do
        let(:other) do
          described_class.new.
            tap { |result| result.errors = ['errors.messages.unknown'] }.
            tap(&:success!)
        end # let

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a result with status set to failure' do
        let(:other) { described_class.new.tap(&:failure!) }

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a result with status set to success' do
        let(:other) { described_class.new.tap(&:success!) }

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a halted result' do
        let(:other) { described_class.new.tap(&:halt!) }

        it { expect(instance == other).to be true }
      end # describe

      describe 'with an uncalled operation' do
        let(:other) { Cuprum::BuiltIn::NullOperation.new }

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a called operation' do
        let(:other) { Cuprum::BuiltIn::NullOperation.new.call }

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a called operation with a value' do
        let(:other) do
          Cuprum::Operation.new do
            'other value'.freeze
          end.call
        end # let

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a called operation with many errors' do
        let(:other) do
          Cuprum::Operation.new do
            errors << 'errors.messages.unknown'

            nil
          end.call
        end # let

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a called operation with many errors and success status' do
        let(:other) do
          Cuprum::Operation.new do
            errors << 'errors.messages.unknown'

            success!

            nil
          end.call
        end # let

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a called operation with status set to failure' do
        let(:other) do
          Cuprum::Operation.new do
            failure!

            nil
          end.call
        end # let

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a called operation with status set to success' do
        let(:other) do
          Cuprum::Operation.new do
            success!

            nil
          end.call
        end # let

        it { expect(instance == other).to be false }
      end # describe

      describe 'with a called and halted operation' do
        let(:other) do
          Cuprum::Operation.new do
            halt!

            nil
          end.call
        end # let

        it { expect(instance == other).to be true }
      end # describe
    end # wrap_context
  end # describe

  describe '#empty?' do
    include_examples 'should have predicate', :empty?, true

    wrap_context 'when the result has a value' do
      it { expect(instance.empty?).to be false }
    end # wrap_context

    wrap_context 'when the result has many errors' do
      it { expect(instance.empty?).to be false }
    end # wrap_context

    wrap_context 'when the result status is set to failure' do
      it { expect(instance.empty?).to be false }
    end # wrap_context

    wrap_context 'when the result status is set to success' do
      it { expect(instance.empty?).to be false }
    end # wrap_context

    wrap_context 'when the result is halted' do
      it { expect(instance.empty?).to be false }
    end # wrap_context
  end # describe

  describe '#errors' do
    include_examples 'should have property', :errors, []
  end # describe

  describe '#failure!' do
    it { expect(instance).to respond_to(:failure!).with(0).arguments }

    it { expect(instance.failure!).to be instance }

    it 'sets the result status to :failure' do
      instance.failure!

      expect(instance.failure?).to be true
    end # it

    wrap_context 'when the result has many errors' do
      it 'sets the result status to :failure' do
        instance.failure!

        expect(instance.failure?).to be true
      end # it
    end # wrap_context

    wrap_context 'when the result status is set to failure' do
      it 'sets the result status to :failure' do
        instance.failure!

        expect(instance.failure?).to be true
      end # it
    end # wrap_context

    wrap_context 'when the result status is set to success' do
      it 'sets the result status to :failure' do
        instance.failure!

        expect(instance.failure?).to be true
      end # it
    end # wrap_context
  end # describe

  describe '#failure?' do
    include_examples 'should have predicate', :failure?, false

    wrap_context 'when the result has many errors' do
      it { expect(instance.failure?).to be true }
    end # wrap_context

    wrap_context 'when the result status is set to failure' do
      it { expect(instance.failure?).to be true }
    end # wrap_context

    wrap_context 'when the result status is set to success' do
      it { expect(instance.failure?).to be false }
    end # wrap_context

    wrap_context 'when the result is halted' do
      it { expect(instance.failure?).to be false }
    end # wrap_context
  end # describe

  describe '#halt!' do
    it { expect(instance).to respond_to(:halt!).with(0).arguments }

    it { expect(instance.halt!).to be instance }

    it 'should mark the result as halted' do
      instance.halt!

      expect(instance.halted?).to be true
    end # it
  end # describe

  describe '#halted?' do
    include_examples 'should have predicate', :halted?, false

    wrap_context 'when the result status is set to failure' do
      it { expect(instance.halted?).to be false }
    end # wrap_context

    wrap_context 'when the result status is set to success' do
      it { expect(instance.halted?).to be false }
    end # wrap_context

    wrap_context 'when the result is halted' do
      it { expect(instance.halted?).to be true }
    end # wrap_context
  end # describe

  describe '#success!' do
    it { expect(instance).to respond_to(:success!).with(0).arguments }

    it { expect(instance.success!).to be instance }

    it 'sets the result status to :success' do
      instance.success!

      expect(instance.success?).to be true
    end # it

    wrap_context 'when the result has many errors' do
      it 'sets the result status to :success' do
        instance.success!

        expect(instance.success?).to be true
      end # it
    end # wrap_context

    wrap_context 'when the result status is set to failure' do
      it 'sets the result status to :success' do
        instance.success!

        expect(instance.success?).to be true
      end # it
    end # wrap_context

    wrap_context 'when the result status is set to success' do
      it 'sets the result status to :success' do
        instance.success!

        expect(instance.success?).to be true
      end # it
    end # wrap_context
  end # describe

  describe '#success?' do
    include_examples 'should have predicate', :success?, true

    wrap_context 'when the result has many errors' do
      it { expect(instance.success?).to be false }
    end # wrap_context

    wrap_context 'when the result status is set to failure' do
      it { expect(instance.success?).to be false }
    end # wrap_context

    wrap_context 'when the result status is set to success' do
      it { expect(instance.success?).to be true }
    end # wrap_context

    wrap_context 'when the result is halted' do
      it { expect(instance.success?).to be true }
    end # wrap_context
  end # describe

  describe '#update' do
    let(:other_value)  { 'other value'.freeze }
    let(:other_errors) { [] }
    let(:other) do
      described_class.new(other_value, :errors => other_errors)
    end # let

    it { expect(instance).to respond_to(:update).with(1).argument }

    describe 'with nil' do
      it { expect(instance.update nil).to be instance }
    end # describe

    describe 'with a result with a value' do
      it { expect(instance.update other).to be instance }

      it { expect(instance.update(other).value).to be == other_value }

      it { expect(instance.update(other).errors).to be_empty }

      it { expect(instance.update(other).failure?).to be false }

      it { expect(instance.update(other).success?).to be true }

      it { expect(instance.update(other).halted?).to be false }
    end # describe

    describe 'with a result with a status set to failure' do
      let(:other) { super().tap(&:failure!) }

      it { expect(instance.update other).to be instance }

      it { expect(instance.update(other).value).to be == other_value }

      it { expect(instance.update(other).errors).to be_empty }

      it { expect(instance.update(other).failure?).to be true }

      it { expect(instance.update(other).success?).to be false }

      it { expect(instance.update(other).halted?).to be false }
    end # describe

    describe 'with a result with a status set to success' do
      let(:other) { super().tap(&:success!) }

      it { expect(instance.update other).to be instance }

      it { expect(instance.update(other).value).to be == other_value }

      it { expect(instance.update(other).errors).to be_empty }

      it { expect(instance.update(other).failure?).to be false }

      it { expect(instance.update(other).success?).to be true }

      it { expect(instance.update(other).halted?).to be false }
    end # describe

    describe 'with a result with errors' do
      let(:other_errors) { ['errors.messages.other'] }

      it { expect(instance.update other).to be instance }

      it { expect(instance.update(other).value).to be == other_value }

      it { expect(instance.update(other).errors).to be == other_errors }

      it { expect(instance.update(other).failure?).to be true }

      it { expect(instance.update(other).success?).to be false }

      it { expect(instance.update(other).halted?).to be false }
    end # describe

    describe 'with a result with errors and a status set to success' do
      let(:other)        { super().tap(&:success!) }
      let(:other_errors) { ['errors.messages.other'] }

      it { expect(instance.update other).to be instance }

      it { expect(instance.update(other).value).to be == other_value }

      it { expect(instance.update(other).errors).to be == other_errors }

      it { expect(instance.update(other).failure?).to be false }

      it { expect(instance.update(other).success?).to be true }

      it { expect(instance.update(other).halted?).to be false }
    end # describe

    describe 'with a result that is halted' do
      let(:other) { super().tap(&:halt!) }

      it { expect(instance.update other).to be instance }

      it { expect(instance.update(other).value).to be == other_value }

      it { expect(instance.update(other).errors).to be_empty }

      it { expect(instance.update(other).failure?).to be false }

      it { expect(instance.update(other).success?).to be true }

      it { expect(instance.update(other).halted?).to be true }
    end # describe

    wrap_context 'when the result has many errors' do
      describe 'with a result with a value' do
        it { expect(instance.update(other).errors).to be == errors }

        it { expect(instance.update(other).failure?).to be true }

        it { expect(instance.update(other).success?).to be false }
      end # describe

      describe 'with a result with a status set to failure' do
        let(:other) { super().tap(&:failure!) }

        it { expect(instance.update(other).errors).to be == errors }

        it { expect(instance.update(other).failure?).to be true }

        it { expect(instance.update(other).success?).to be false }
      end # describe

      describe 'with a result with a status set to success' do
        let(:other) { super().tap(&:success!) }

        it { expect(instance.update(other).errors).to be == errors }

        it { expect(instance.update(other).failure?).to be true }

        it { expect(instance.update(other).success?).to be false }
      end # describe

      describe 'with a result with errors' do
        let(:other_errors)    { ['errors.messages.other'] }
        let(:expected_errors) { errors + other_errors }

        it 'should merge the errors' do
          expect(instance.update(other).errors).
            to contain_exactly(*expected_errors)
        end # it

        it { expect(instance.update(other).failure?).to be true }

        it { expect(instance.update(other).success?).to be false }
      end # describe

      describe 'with a result with errors and a status set to success' do
        let(:other)           { super().tap(&:success!) }
        let(:other_errors)    { ['errors.messages.other'] }
        let(:expected_errors) { errors + other_errors }

        it 'should merge the errors' do
          expect(instance.update(other).errors).
            to contain_exactly(*expected_errors)
        end # it

        it { expect(instance.update(other).failure?).to be true }

        it { expect(instance.update(other).success?).to be false }
      end # describe

      describe 'with a result that is halted' do
        let(:other) { super().tap(&:halt!) }

        it { expect(instance.update(other).errors).to be == errors }

        it { expect(instance.update(other).failure?).to be true }

        it { expect(instance.update(other).success?).to be false }
      end # describe

      wrap_context 'when the result status is set to success' do
        describe 'with a result with a value' do
          it { expect(instance.update(other).errors).to be == errors }

          it { expect(instance.update(other).failure?).to be false }

          it { expect(instance.update(other).success?).to be true }
        end # describe

        describe 'with a result with a status set to failure' do
          let(:other) { super().tap(&:failure!) }

          it { expect(instance.update(other).errors).to be == errors }

          it { expect(instance.update(other).failure?).to be false }

          it { expect(instance.update(other).success?).to be true }
        end # describe

        describe 'with a result with a status set to success' do
          let(:other) { super().tap(&:success!) }

          it { expect(instance.update(other).errors).to be == errors }

          it { expect(instance.update(other).failure?).to be false }

          it { expect(instance.update(other).success?).to be true }
        end # describe

        describe 'with a result with errors' do
          let(:other_errors)    { ['errors.messages.other'] }
          let(:expected_errors) { errors + other_errors }

          it 'should merge the errors' do
            expect(instance.update(other).errors).
              to contain_exactly(*expected_errors)
          end # it

          it { expect(instance.update(other).failure?).to be false }

          it { expect(instance.update(other).success?).to be true }
        end # describe

        describe 'with a result with errors and a status set to success' do
          let(:other)           { super().tap(&:success!) }
          let(:other_errors)    { ['errors.messages.other'] }
          let(:expected_errors) { errors + other_errors }

          it 'should merge the errors' do
            expect(instance.update(other).errors).
              to contain_exactly(*expected_errors)
          end # it

          it { expect(instance.update(other).failure?).to be false }

          it { expect(instance.update(other).success?).to be true }
        end # describe

        describe 'with a result that is halted' do
          let(:other) { super().tap(&:halt!) }

          it { expect(instance.update(other).errors).to be == errors }

          it { expect(instance.update(other).failure?).to be false }

          it { expect(instance.update(other).success?).to be true }
        end # describe
      end # wrap_context
    end # wrap_context

    wrap_context 'when the result status is set to failure' do
      describe 'with a result with a value' do
        it { expect(instance.update(other).failure?).to be true }
      end # describe

      describe 'with a result with a status set to failure' do
        let(:other) { super().tap(&:failure!) }

        it { expect(instance.update(other).failure?).to be true }
      end # describe

      describe 'with a result with a status set to success' do
        let(:other) { super().tap(&:success!) }

        it { expect(instance.update(other).failure?).to be true }
      end # describe

      describe 'with a result with errors' do
        let(:other_errors)    { ['errors.messages.other'] }

        it { expect(instance.update(other).failure?).to be true }
      end # describe

      describe 'with a result with errors and a status set to success' do
        let(:other)        { super().tap(&:success!) }
        let(:other_errors) { ['errors.messages.other'] }

        it { expect(instance.update(other).failure?).to be true }
      end # describe

      describe 'with a result that is halted' do
        let(:other) { super().tap(&:halt!) }

        it { expect(instance.update(other).failure?).to be true }
      end # describe
    end # wrap_context

    wrap_context 'when the result status is set to success' do
      describe 'with a result with a value' do
        it { expect(instance.update(other).success?).to be true }
      end # describe

      describe 'with a result with a status set to failure' do
        let(:other) { super().tap(&:failure!) }

        it { expect(instance.update(other).success?).to be true }
      end # describe

      describe 'with a result with a status set to success' do
        let(:other) { super().tap(&:success!) }

        it { expect(instance.update(other).success?).to be true }
      end # describe

      describe 'with a result with errors' do
        let(:other_errors)    { ['errors.messages.other'] }

        it { expect(instance.update(other).success?).to be true }
      end # describe

      describe 'with a result with errors and a status set to success' do
        let(:other)        { super().tap(&:success!) }
        let(:other_errors) { ['errors.messages.other'] }

        it { expect(instance.update(other).success?).to be true }
      end # describe

      describe 'with a result that is halted' do
        let(:other) { super().tap(&:halt!) }

        it { expect(instance.update(other).success?).to be true }
      end # describe
    end # wrap_context

    wrap_context 'when the result is halted' do
      describe 'with a result with a value' do
        it { expect(instance.update(other).halted?).to be true }
      end # describe

      describe 'with a result with a status set to failure' do
        let(:other) { super().tap(&:failure!) }

        it { expect(instance.update(other).halted?).to be true }
      end # describe

      describe 'with a result with a status set to success' do
        let(:other) { super().tap(&:success!) }

        it { expect(instance.update(other).halted?).to be true }
      end # describe

      describe 'with a result with errors' do
        let(:other_errors)    { ['errors.messages.other'] }

        it { expect(instance.update(other).halted?).to be true }
      end # describe

      describe 'with a result with errors and a status set to success' do
        let(:other)        { super().tap(&:success!) }
        let(:other_errors) { ['errors.messages.other'] }

        it { expect(instance.update(other).halted?).to be true }
      end # describe

      describe 'with a result that is halted' do
        let(:other) { super().tap(&:halt!) }

        it { expect(instance.update(other).halted?).to be true }
      end # describe
    end # wrap_context
  end # describe

  describe '#value' do
    include_examples 'should have property', :value, nil
  end # describe
end # describe
