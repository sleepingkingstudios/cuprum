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

  shared_context 'when the result has status: :failure' do
    before(:example) { params[:status] = :failure }
  end

  shared_context 'when the result has status: :success' do
    before(:example) { params[:status] = :success }
  end

  subject(:instance) { described_class.new(params) }

  let(:params) { {} }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:error, :status, :value)
    end

    describe 'with status: :failure' do
      let(:instance) { described_class.new(status: :failure) }

      it { expect(instance.status).to be :failure }
    end

    describe 'with status: "failure"' do
      let(:instance) { described_class.new(status: 'failure') }

      it { expect(instance.status).to be :failure }
    end

    describe 'with status: :success' do
      let(:instance) { described_class.new(status: :success) }

      it { expect(instance.status).to be :success }
    end

    describe 'with status: "success"' do
      let(:instance) { described_class.new(status: 'success') }

      it { expect(instance.status).to be :success }
    end

    describe 'with status: invalid object' do
      let(:status)        { Object.new.freeze }
      let(:error_message) { "invalid status #{status.inspect}" }

      it 'should raise an error' do
        expect { described_class.new(status: status) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with status: invalid value' do
      let(:status)        { :invalid }
      let(:error_message) { "invalid status #{status.inspect}" }

      it 'should raise an error' do
        expect { described_class.new(status: status) }
          .to raise_error ArgumentError, error_message
      end
    end
  end

  describe '#==' do
    shared_context 'with an object that wraps a result' do
      let(:other) { Spec::ResultWrapper.new(result) }

      example_class 'Spec::ResultWrapper', Struct.new(:result) do |klass|
        klass.extend Forwardable

        klass.def_delegators :result, :error, :status, :value
      end
    end

    shared_examples 'should compare the results' do |value:, error:, status:|
      let(:other_value)  { value }
      let(:other_error)  { error }
      let(:other_status) { status }
      let(:result) do
        described_class.new(
          value:  other_value,
          error:  other_error,
          status: other_status
        )
      end
      let(:other) { defined?(super()) ? super() : result }
      let(:expected) do
        %i[error status value]
          .map { |method| instance.send(method) == other.send(method) }
          .reduce(true) { |memo, bool| memo && bool }
      end

      it { expect(instance == other).to be expected }
    end

    value_scenarios = {
      'a nil value'          => nil,
      'a non-matching value' => 'other value'
    }
    error_scenarios = {
      'a nil error'          => nil,
      'a non-matching error' =>
        Cuprum::Error.new(message: 'Other error message.')
    }
    status_scenarios = {
      ''                 => nil,
      'status: :failure' => :failure,
      'status: :success' => :success
    }
    default_scenarios = {
      value:  value_scenarios,
      error:  error_scenarios,
      status: status_scenarios
    }

    def self.compare_results(**scenarios)
      Spec::Matrix.new(self).evaluate(scenarios) do |value:, error:, status:|
        include_examples 'should compare the results',
          value:  value,
          error:  error,
          status: status
      end
    end

    describe 'with nil' do
      # rubocop:disable Style/NilComparison
      it { expect(instance == nil).to be false }
      # rubocop:enable Style/NilComparison
    end

    compare_results(default_scenarios)

    wrap_context 'with an object that wraps a result' do
      compare_results(default_scenarios)
    end

    wrap_context 'when the result has a value' do
      all_scenarios = {
        value:
          value_scenarios.merge('a matching value' => 'returned value'),
        error:  error_scenarios,
        status: status_scenarios
      }

      compare_results(all_scenarios)

      wrap_context 'with an object that wraps a result' do
        compare_results(all_scenarios)
      end

      wrap_context 'when the result has status: :failure' do
        compare_results(all_scenarios)

        wrap_context 'with an object that wraps a result' do
          compare_results(all_scenarios)
        end
      end

      wrap_context 'when the result has status: :success' do
        compare_results(all_scenarios)

        wrap_context 'with an object that wraps a result' do
          compare_results(all_scenarios)
        end
      end
    end

    wrap_context 'when the result has an error' do
      all_scenarios = {
        value:  value_scenarios,
        error:  error_scenarios.merge(
          'a matching error' => Cuprum::Error.new(
            message: 'Something went wrong.'
          )
        ),
        status: status_scenarios
      }

      compare_results(all_scenarios)

      wrap_context 'with an object that wraps a result' do
        compare_results(all_scenarios)
      end

      wrap_context 'when the result has status: :failure' do
        compare_results(all_scenarios)

        wrap_context 'with an object that wraps a result' do
          compare_results(all_scenarios)
        end
      end

      wrap_context 'when the result has status: :success' do
        compare_results(all_scenarios)

        wrap_context 'with an object that wraps a result' do
          compare_results(all_scenarios)
        end
      end
    end

    context 'when the result has a value and an error' do
      include_context 'when the result has a value'
      include_context 'when the result has an error'

      all_scenarios = {
        value:
          value_scenarios.merge('a matching value' => 'returned value'),
        error:  error_scenarios.merge(
          'a matching error' => Cuprum::Error.new(
            message: 'Something went wrong.'
          )
        ),
        status: status_scenarios
      }

      compare_results(all_scenarios)

      wrap_context 'with an object that wraps a result' do
        compare_results(all_scenarios)
      end

      wrap_context 'when the result has status: :failure' do
        compare_results(all_scenarios)

        wrap_context 'with an object that wraps a result' do
          compare_results(all_scenarios)
        end
      end

      wrap_context 'when the result has status: :success' do
        compare_results(all_scenarios)

        wrap_context 'with an object that wraps a result' do
          compare_results(all_scenarios)
        end
      end
    end

    wrap_context 'when the result has status: :failure' do
      compare_results(default_scenarios)

      wrap_context 'with an object that wraps a result' do
        compare_results(default_scenarios)
      end
    end

    wrap_context 'when the result has status: :success' do
      compare_results(default_scenarios)

      wrap_context 'with an object that wraps a result' do
        compare_results(default_scenarios)
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

      wrap_context 'when the result has status: :failure' do
        it { expect(instance.failure?).to be true }
      end

      wrap_context 'when the result has status: :success' do
        it { expect(instance.failure?).to be false }
      end
    end

    wrap_context 'when the result has status: :failure' do
      it { expect(instance.failure?).to be true }
    end

    wrap_context 'when the result has status: :success' do
      it { expect(instance.failure?).to be false }
    end
  end

  describe '#status' do
    include_examples 'should have reader', :status, :success

    wrap_context 'when the result has an error' do
      it { expect(instance.status).to be :failure }

      wrap_context 'when the result has status: :failure' do
        it { expect(instance.status).to be :failure }
      end

      wrap_context 'when the result has status: :success' do
        it { expect(instance.status).to be :success }
      end
    end

    wrap_context 'when the result has status: :failure' do
      it { expect(instance.status).to be :failure }
    end

    wrap_context 'when the result has status: :success' do
      it { expect(instance.status).to be :success }
    end
  end

  describe '#success?' do
    include_examples 'should have predicate', :success?, true

    wrap_context 'when the result has an error' do
      it { expect(instance.success?).to be false }

      wrap_context 'when the result has status: :failure' do
        it { expect(instance.success?).to be false }
      end

      wrap_context 'when the result has status: :success' do
        it { expect(instance.success?).to be true }
      end
    end

    wrap_context 'when the result has status: :failure' do
      it { expect(instance.success?).to be false }
    end

    wrap_context 'when the result has status: :success' do
      it { expect(instance.success?).to be true }
    end
  end

  describe '#to_cuprum_result' do
    include_examples 'should have reader', :to_cuprum_result, ->() { instance }
  end

  describe '#value' do
    include_examples 'should have property', :value, nil

    context 'when initialized with a hash value' do
      let(:value)    { 'result value' }
      let(:instance) { described_class.new(value: value) }

      it { expect(instance.value).to be value }
    end

    context 'when initialized with a string value' do
      let(:value)    { { key: 'returned value' } }
      let(:instance) { described_class.new(value: value) }

      it { expect(instance.value).to be value }
    end
  end
end
