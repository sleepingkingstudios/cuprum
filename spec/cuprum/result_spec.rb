# frozen_string_literal: true

require 'cuprum/built_in/null_operation'
require 'cuprum/result'

RSpec.describe Cuprum::Result do
  shared_context 'when the result has a value' do
    let(:value) { 'returned value' }

    before(:example) { instance.value = value }
  end

  shared_context 'when the result has many errors' do
    let(:errors) { ['errors.messages.unknown'] }

    before(:example) do
      instance.errors = errors
    end
  end

  subject(:instance) { described_class.new }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:errors, :value)
    end

    describe 'with an errors object' do
      let(:errors)   { ['errors.messages.unknown'] }
      let(:instance) { described_class.new(errors: errors) }

      it { expect(instance.errors).to be errors }

      it { expect(instance.failure?).to be true }
    end

    describe 'with a hash value' do
      let(:value)    { { key: 'returned value' } }
      let(:instance) { described_class.new(value: value) }

      it { expect(instance.value).to be value }

      it { expect(instance.success?).to be true }
    end

    describe 'with a string value' do
      let(:value)    { 'returned value' }
      let(:instance) { described_class.new(value: value) }

      it { expect(instance.value).to be value }

      it { expect(instance.success?).to be true }
    end

    describe 'with a value and an errors object' do
      let(:value)    { 'returned value' }
      let(:errors)   { ['errors.messages.unknown'] }
      let(:instance) { described_class.new(value: value, errors: errors) }

      it { expect(instance.value).to be value }

      it { expect(instance.errors).to be errors }

      it { expect(instance.failure?).to be true }
    end
  end

  describe '#==' do
    describe 'with nil' do
      # rubocop:disable Style/NilComparison
      it { expect(instance == nil).to be false }
      # rubocop:enable Style/NilComparison
    end

    describe 'with an empty result' do
      let(:other) { described_class.new }

      it { expect(instance == other).to be true }
    end

    describe 'with a result with a value' do
      let(:other) { described_class.new(value: 'other value') }

      it { expect(instance == other).to be false }
    end

    describe 'with a result with many errors' do
      let(:other) { described_class.new(errors: ['errors.messages.unknown']) }

      it { expect(instance == other).to be false }
    end

    describe 'with an uncalled operation' do
      let(:other) { Cuprum::BuiltIn::NullOperation.new }

      it { expect(instance == other).to be false }
    end

    describe 'with a called operation' do
      let(:other) { Cuprum::BuiltIn::NullOperation.new.call }

      it { expect(instance == other).to be true }
    end

    describe 'with a called operation with a value' do
      let(:other) { Cuprum::Operation.new { 'other value' }.call }

      it { expect(instance == other).to be false }
    end

    describe 'with a called operation with many errors' do
      let(:other) do
        Cuprum::Operation.new do
          # rubocop:disable RSpec/DescribedClass
          Cuprum::Result.new(errors: ['errors.messages.unknown'])
          # rubocop:enable RSpec/DescribedClass
        end.call
      end

      it { expect(instance == other).to be false }
    end

    wrap_context 'when the result has a value' do
      describe 'with an empty result' do
        let(:other) { described_class.new }

        it { expect(instance == other).to be false }
      end

      describe 'with a result with a non-matching value' do
        let(:other) { described_class.new(value: 'other value') }

        it { expect(instance == other).to be false }
      end

      describe 'with a result with a matching value' do
        let(:other) { described_class.new(value: value) }

        it { expect(instance == other).to be true }
      end

      describe 'with a called operation with many errors' do
        let(:other) do
          Cuprum::Operation.new do
            # rubocop:disable RSpec/DescribedClass
            Cuprum::Result.new(errors: ['errors.messages.unknown'])
            # rubocop:enable RSpec/DescribedClass
          end.call
        end

        it { expect(instance == other).to be false }
      end
    end

    wrap_context 'when the result has many errors' do
      describe 'with an empty result' do
        let(:other) { described_class.new }

        it { expect(instance == other).to be false }
      end

      describe 'with a result with a value' do
        let(:other) { described_class.new(value: 'other value') }

        it { expect(instance == other).to be false }
      end

      describe 'with a result with non-matching errors' do
        let(:other) { described_class.new(errors: ['errors.messages.other']) }

        it { expect(instance == other).to be false }
      end

      describe 'with a result with matching errors' do
        let(:other) do
          described_class.new(errors: ['errors.messages.unknown'])
        end

        it { expect(instance == other).to be true }
      end

      describe 'with an uncalled operation' do
        let(:other) { Cuprum::BuiltIn::NullOperation.new }

        it { expect(instance == other).to be false }
      end

      describe 'with a called operation' do
        let(:other) { Cuprum::BuiltIn::NullOperation.new.call }

        it { expect(instance == other).to be false }
      end

      describe 'with a called operation with a value' do
        let(:other) do
          Cuprum::Operation.new { 'other value' }.call
        end

        it { expect(instance == other).to be false }
      end

      describe 'with a called operation with non-matching errors' do
        let(:other) do
          Cuprum::Operation.new do
            # rubocop:disable RSpec/DescribedClass
            Cuprum::Result.new(errors: ['errors.messages.other'])
            # rubocop:enable RSpec/DescribedClass
          end.call
        end

        it { expect(instance == other).to be false }
      end

      describe 'with a called operation with matching errors' do
        let(:other) do
          Cuprum::Operation.new do
            # rubocop:disable RSpec/DescribedClass
            Cuprum::Result.new(errors: ['errors.messages.unknown'])
            # rubocop:enable RSpec/DescribedClass
          end.call
        end

        it { expect(instance == other).to be true }
      end
    end
  end

  describe '#errors' do
    include_examples 'should have property', :errors, nil

    context 'when initialized with an errors object' do
      let(:errors)   { ['spec.errors.something_went_wrong'] }
      let(:instance) { described_class.new(errors: errors) }

      it { expect(instance.errors).to be errors }
    end
  end

  describe '#failure?' do
    include_examples 'should have predicate', :failure?, false

    wrap_context 'when the result has many errors' do
      it { expect(instance.failure?).to be true }
    end
  end

  describe '#success?' do
    include_examples 'should have predicate', :success?, true

    wrap_context 'when the result has many errors' do
      it { expect(instance.success?).to be false }
    end
  end

  describe '#to_cuprum_result' do
    include_examples 'should have reader', :to_cuprum_result, ->() { instance }
  end

  describe '#value' do
    include_examples 'should have property', :value, nil

    context 'when initialized with a value' do
      let(:value)    { 'result value' }
      let(:instance) { described_class.new(value: value) }

      it { expect(instance.value).to be value }
    end
  end
end
