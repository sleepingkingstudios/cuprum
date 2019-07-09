# frozen_string_literal: true

require 'forwardable'

require 'cuprum/error'
require 'cuprum/result'

RSpec.describe Cuprum::Result do
  shared_context 'when the result has a value' do
    let(:value) { 'returned value' }

    before(:example) { params[:value] = value }
  end

  shared_context 'when the result has an error' do
    let(:error) { Cuprum::Error.new(message: 'Something went wrong.') }

    before(:example) { params[:error] = error }
  end

  subject(:instance) { described_class.new(params) }

  let(:params) { {} }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:error, :value)
    end

    describe 'with an error object' do
      let(:error)    { Cuprum::Error.new(message: 'Something went wrong.') }
      let(:instance) { described_class.new(error: error) }

      it { expect(instance.error).to be error }

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

    describe 'with a value and an error object' do
      let(:value)    { 'returned value' }
      let(:error)    { Cuprum::Error.new(message: 'Something went wrong.') }
      let(:instance) { described_class.new(value: value, error: error) }

      it { expect(instance.value).to be value }

      it { expect(instance.error).to be error }

      it { expect(instance.failure?).to be true }
    end
  end

  describe '#==' do
    shared_context 'with an object that wraps a result' do
      let(:other) { Spec::ResultWrapper.new(result) }

      example_class 'Spec::ResultWrapper', Struct.new(:result) do |klass|
        klass.extend Forwardable

        klass.def_delegators :result, :error, :success?, :value
      end
    end

    shared_examples 'should compare the results' do
      let(:expected) do
        %i[error success? value]
          .map { |method| instance.send(method) == other.send(method) }
          .reduce(true) { |memo, bool| memo && bool }
      end

      it { expect(instance == other).to be expected }
    end

    shared_examples 'should compare the results by property' do
      describe 'with an empty result' do
        let(:result) { described_class.new }

        include_examples 'should compare the results'
      end

      describe 'with a result with a non-matching value' do
        let(:result) { described_class.new(value: 'other value') }

        include_examples 'should compare the results'
      end

      describe 'with a result with a non-matching error' do
        let(:result) { described_class.new(error: Cuprum::Error.new) }

        include_examples 'should compare the results'
      end
    end

    let(:other) { result }

    describe 'with nil' do
      # rubocop:disable Style/NilComparison
      it { expect(instance == nil).to be false }
      # rubocop:enable Style/NilComparison
    end

    include_examples 'should compare the results by property'

    wrap_context 'with an object that wraps a result' do
      include_examples 'should compare the results by property'
    end

    wrap_context 'when the result has a value' do
      include_examples 'should compare the results by property'

      describe 'with a result with a matching value' do
        let(:result) { described_class.new(value: value) }

        include_examples 'should compare the results'
      end

      wrap_context 'with an object that wraps a result' do
        include_examples 'should compare the results by property'

        describe 'with a result with a matching value' do
          let(:result) { described_class.new(value: value) }

          include_examples 'should compare the results'
        end
      end
    end

    wrap_context 'when the result has an error' do
      include_examples 'should compare the results by property'

      wrap_context 'with an object that wraps a result' do
        include_examples 'should compare the results by property'
      end
    end
  end

  describe '#error' do
    include_examples 'should have property', :error, nil

    wrap_context 'when the result has an error' do
      it { expect(instance.error).to be error }
    end
  end

  describe '#failure?' do
    include_examples 'should have predicate', :failure?, false

    wrap_context 'when the result has an error' do
      it { expect(instance.failure?).to be true }
    end
  end

  describe '#success?' do
    include_examples 'should have predicate', :success?, true

    wrap_context 'when the result has an error' do
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
