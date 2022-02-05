# frozen_string_literal: true

require 'cuprum/result_list'
require 'cuprum/rspec/be_a_result'

RSpec.describe Cuprum::ResultList do
  include Cuprum::RSpec::Matchers

  subject(:result_list) { described_class.new(*results, **constructor_options) }

  shared_context 'when initialized with allow_partial: true' do
    let(:constructor_options) { super().merge(allow_partial: true) }
  end

  shared_context 'when initialized with value: an Object' do
    let(:value)               { { 'values' => results.map(&:value) } }
    let(:constructor_options) { super().merge(value: value) }
  end

  shared_context 'when initialized with failing results' do
    let(:results) do
      [
        Cuprum::Result.new(
          status: :failure
        ),
        Cuprum::Result.new(
          status: :failure,
          error:  Cuprum::Error.new(message: 'Something went wrong')
        ),
        Cuprum::Result.new(
          status: :failure,
          error:  Cuprum::Error.new(message: 'Please try again'),
          value:  'Example value'
        )
      ]
    end
  end

  shared_context 'when initialized with passing results' do
    let(:results) do
      [
        Cuprum::Result.new(
          status: :success
        ),
        Cuprum::Result.new(
          status: :success,
          value:  'Example value'
        ),
        Cuprum::Result.new(
          status: :success,
          error:  Cuprum::Error.new(message: 'Are you sure this passed?'),
          value:  'Another value'
        )
      ]
    end
  end

  shared_context 'when initialized with mixed results' do
    let(:results) do
      [
        Cuprum::Result.new(
          status: :success
        ),
        Cuprum::Result.new(
          status: :failure,
          error:  Cuprum::Error.new(message: 'Please try again'),
          value:  'Example value'
        ),
        Cuprum::Result.new(
          status: :success,
          error:  Cuprum::Error.new(message: 'Are you sure this passed?'),
          value:  'Another value'
        )
      ]
    end
  end

  let(:results)             { [] }
  let(:constructor_options) { {} }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with_unlimited_arguments
        .and_keywords(:allow_partial, :value)
    end

    describe 'with nil' do
      let(:error_message) do
        'invalid result: nil does not respond to #to_cuprum_result'
      end

      it 'should raise an exception' do
        expect { described_class.new(nil) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an Object' do
      let(:object) { Object.new.freeze }
      let(:error_message) do
        "invalid result: #{object.inspect} does not respond to" \
          ' #to_cuprum_result'
      end

      it 'should raise an exception' do
        expect { described_class.new(object) }
          .to raise_error ArgumentError, error_message
      end
    end
  end

  it { expect(described_class).to be < Enumerable }

  describe '#==' do
    describe 'with nil' do
      it { expect(result_list == nil).to be false } # rubocop:disable Style/NilComparison
    end

    describe 'with an Object' do
      it { expect(result_list == Object.new.freeze).to be false }
    end

    describe 'with an empty ResultList with non-matching options' do
      let(:other_list) { described_class.new(allow_partial: true) }

      it { expect(result_list == other_list).to be false }
    end

    describe 'with an empty ResultList with non-matching results' do
      let(:other_results) { Array.new(3) { Cuprum::Result.new } }
      let(:other_list)    { described_class.new(*other_results) }

      it { expect(result_list == other_list).to be false }
    end

    describe 'with an empty ResultList with matching results and options' do
      let(:other_list) { described_class.new(allow_partial: false) }

      it { expect(result_list == other_list).to be true }
    end

    context 'when initialized with results' do
      include_context 'when initialized with mixed results'

      describe 'with an empty ResultList with non-matching options' do
        let(:other_list) do
          described_class.new(*results, allow_partial: true)
        end

        it { expect(result_list == other_list).to be false }
      end

      describe 'with an empty ResultList with non-matching results' do
        let(:other_results) { Array.new(3) { Cuprum::Result.new } }
        let(:other_list)    { described_class.new(*other_results) }

        it { expect(result_list == other_list).to be false }
      end

      describe 'with an empty ResultList with matching results and options' do
        let(:other_list) do
          described_class.new(*results, allow_partial: false)
        end

        it { expect(result_list == other_list).to be true }
      end
    end

    wrap_context 'when initialized with allow_partial: true' do
      describe 'with an empty ResultList with non-matching options' do
        let(:other_list) { described_class.new(allow_partial: false) }

        it { expect(result_list == other_list).to be false }
      end

      describe 'with an empty ResultList with matching results and options' do
        let(:other_list) { described_class.new(allow_partial: true) }

        it { expect(result_list == other_list).to be true }
      end

      context 'when initialized with results' do
        include_context 'when initialized with mixed results'

        describe 'with an empty ResultList with non-matching options' do
          let(:other_list) do
            described_class.new(*results, allow_partial: false)
          end

          it { expect(result_list == other_list).to be false }
        end

        describe 'with an empty ResultList with non-matching results' do
          let(:other_results) { Array.new(3) { Cuprum::Result.new } }
          let(:other_list)    { described_class.new(*other_results) }

          it { expect(result_list == other_list).to be false }
        end

        describe 'with an empty ResultList with matching results and options' do
          let(:other_list) do
            described_class.new(*results, allow_partial: true)
          end

          it { expect(result_list == other_list).to be true }
        end
      end
    end
  end

  describe '#allow_partial' do
    include_examples 'should define predicate', :allow_partial?, false

    wrap_context 'when initialized with allow_partial: true' do
      it { expect(result_list.allow_partial?).to be true }
    end
  end

  describe '#each' do
    shared_examples 'should iterate over the results' do
      it { expect(result_list.each.to_a).to be == results }

      describe 'with a block' do
        it 'should yield the results to the block' do
          expect { |block| result_list.each(&block) }
            .to yield_successive_args(*results)
        end
      end
    end

    it 'should define the method' do
      expect(result_list).to respond_to(:each).with(0).arguments.and_a_block
    end

    it { expect(result_list.each).to be_a Enumerator }

    include_examples 'should iterate over the results'

    # rubocop:disable RSpec/RepeatedExampleGroupBody
    wrap_context 'when initialized with failing results' do
      include_examples 'should iterate over the results'
    end

    wrap_context 'when initialized with passing results' do
      include_examples 'should iterate over the results'
    end

    wrap_context 'when initialized with mixed results' do
      include_examples 'should iterate over the results'
    end
    # rubocop:enable RSpec/RepeatedExampleGroupBody
  end

  describe '#error' do
    include_examples 'should define reader', :error, nil

    context 'when initialized with results with no errors' do
      let(:results) do
        Array.new(3) do |index|
          Cuprum::Result.new(status: index.even? ? :success : :failure)
        end
      end

      it { expect(result_list.error).to be nil }
    end

    # rubocop:disable RSpec/RepeatedExampleGroupBody
    wrap_context 'when initialized with failing results' do
      let(:expected_error) do
        Cuprum::Errors::MultipleErrors.new(errors: result_list.errors)
      end

      it { expect(result_list.error).to be == expected_error }
    end

    wrap_context 'when initialized with passing results' do
      let(:expected_error) do
        Cuprum::Errors::MultipleErrors.new(errors: result_list.errors)
      end

      it { expect(result_list.error).to be == expected_error }
    end

    wrap_context 'when initialized with mixed results' do
      let(:expected_error) do
        Cuprum::Errors::MultipleErrors.new(errors: result_list.errors)
      end

      it { expect(result_list.error).to be == expected_error }
    end
    # rubocop:enable RSpec/RepeatedExampleGroupBody
  end

  describe '#errors' do
    include_examples 'should define reader', :errors, []

    # rubocop:disable RSpec/RepeatedExampleGroupBody
    wrap_context 'when initialized with failing results' do
      it { expect(result_list.errors).to be == results.map(&:error) }
    end

    wrap_context 'when initialized with passing results' do
      it { expect(result_list.errors).to be == results.map(&:error) }
    end

    wrap_context 'when initialized with mixed results' do
      it { expect(result_list.errors).to be == results.map(&:error) }
    end
    # rubocop:enable RSpec/RepeatedExampleGroupBody
  end

  describe '#failure?' do
    include_examples 'should define predicate', :failure?, false

    # rubocop:disable RSpec/RepeatedExampleGroupBody
    wrap_context 'when initialized with failing results' do
      it { expect(result_list.failure?).to be true }
    end

    wrap_context 'when initialized with passing results' do
      it { expect(result_list.failure?).to be false }
    end

    wrap_context 'when initialized with mixed results' do
      it { expect(result_list.failure?).to be true }
    end
    # rubocop:enable RSpec/RepeatedExampleGroupBody

    wrap_context 'when initialized with allow_partial: true' do
      it { expect(result_list.failure?).to be false }

      wrap_context 'when initialized with failing results' do
        it { expect(result_list.failure?).to be true }
      end

      # rubocop:disable RSpec/RepeatedExampleGroupBody
      wrap_context 'when initialized with passing results' do
        it { expect(result_list.failure?).to be false }
      end

      wrap_context 'when initialized with mixed results' do
        it { expect(result_list.failure?).to be false }
      end
      # rubocop:enable RSpec/RepeatedExampleGroupBody
    end
  end

  describe '#results' do
    include_examples 'should define reader', :results, -> { be == results }

    it { expect(result_list).to have_aliased_method(:results).as(:to_a) }

    # rubocop:disable RSpec/RepeatedExampleGroupBody
    wrap_context 'when initialized with failing results' do
      it { expect(result_list.results).to be == results }
    end

    wrap_context 'when initialized with passing results' do
      it { expect(result_list.results).to be == results }
    end

    wrap_context 'when initialized with mixed results' do
      it { expect(result_list.results).to be == results }
    end
    # rubocop:enable RSpec/RepeatedExampleGroupBody

    context 'when initialized with result-like objects' do
      subject(:result_list) do
        described_class.new(*wrapped, **constructor_options)
      end

      let(:results) do
        Array.new(3) { |index| Cuprum::Result.new(value: index) }
      end
      let(:wrapped) do
        results.map { |result| Spec::ResultWrapper.new(result) }
      end

      example_class 'Spec::ResultWrapper', Struct.new(:to_cuprum_result)

      it { expect(result_list.results).to be == results }
    end

    context 'when initialized with result lists' do
      let(:results) do
        Array.new(3) do
          described_class.new(*Array.new(3) { Cuprum::Result.new })
        end
      end

      it { expect(result_list).to all be_a(described_class) }

      it { expect(result_list.results).to be == results }
    end
  end

  describe '#status' do
    include_examples 'should define reader', :status, :success

    # rubocop:disable RSpec/RepeatedExampleGroupBody
    wrap_context 'when initialized with failing results' do
      it { expect(result_list.status).to be :failure }
    end

    wrap_context 'when initialized with passing results' do
      it { expect(result_list.status).to be :success }
    end

    wrap_context 'when initialized with mixed results' do
      it { expect(result_list.status).to be :failure }
    end
    # rubocop:enable RSpec/RepeatedExampleGroupBody

    wrap_context 'when initialized with allow_partial: true' do
      it { expect(result_list.status).to be :success }

      wrap_context 'when initialized with failing results' do
        it { expect(result_list.status).to be :failure }
      end

      # rubocop:disable RSpec/RepeatedExampleGroupBody
      wrap_context 'when initialized with passing results' do
        it { expect(result_list.status).to be :success }
      end

      wrap_context 'when initialized with mixed results' do
        it { expect(result_list.status).to be :success }
      end
      # rubocop:enable RSpec/RepeatedExampleGroupBody
    end
  end

  describe '#statuses' do
    include_examples 'should define reader', :statuses, []

    # rubocop:disable RSpec/RepeatedExampleGroupBody
    wrap_context 'when initialized with failing results' do
      it { expect(result_list.statuses).to be == results.map(&:status) }
    end

    wrap_context 'when initialized with passing results' do
      it { expect(result_list.statuses).to be == results.map(&:status) }
    end

    wrap_context 'when initialized with mixed results' do
      it { expect(result_list.statuses).to be == results.map(&:status) }
    end
    # rubocop:enable RSpec/RepeatedExampleGroupBody
  end

  describe '#success?' do
    include_examples 'should define predicate', :success?, true

    # rubocop:disable RSpec/RepeatedExampleGroupBody
    wrap_context 'when initialized with failing results' do
      it { expect(result_list.success?).to be false }
    end

    wrap_context 'when initialized with passing results' do
      it { expect(result_list.success?).to be true }
    end

    wrap_context 'when initialized with mixed results' do
      it { expect(result_list.success?).to be false }
    end
    # rubocop:enable RSpec/RepeatedExampleGroupBody

    wrap_context 'when initialized with allow_partial: true' do
      it { expect(result_list.success?).to be true }

      wrap_context 'when initialized with failing results' do
        it { expect(result_list.success?).to be false }
      end

      # rubocop:disable RSpec/RepeatedExampleGroupBody
      wrap_context 'when initialized with passing results' do
        it { expect(result_list.success?).to be true }
      end

      wrap_context 'when initialized with mixed results' do
        it { expect(result_list.success?).to be true }
      end
      # rubocop:enable RSpec/RepeatedExampleGroupBody
    end
  end

  describe '#to_cuprum_result' do
    it { expect(result_list).to respond_to(:to_cuprum_result) }

    it 'should return a passing result' do
      expect(result_list.to_cuprum_result)
        .to be_a_passing_result
        .with_value(result_list.value)
        .and_error(result_list.error)
    end

    wrap_context 'when initialized with value: an Object' do
      it 'should return a passing result' do
        expect(result_list.to_cuprum_result)
          .to be_a_passing_result
          .with_value(result_list.value)
          .and_error(result_list.error)
      end
    end

    # rubocop:disable RSpec/RepeatedExampleGroupBody
    wrap_context 'when initialized with failing results' do
      it 'should return a failing result' do
        expect(result_list.to_cuprum_result)
          .to be_a_failing_result
          .with_value(result_list.value)
          .and_error(result_list.error)
      end

      wrap_context 'when initialized with value: an Object' do
        it 'should return a passing result' do
          expect(result_list.to_cuprum_result)
            .to be_a_failing_result
            .with_value(result_list.value)
            .and_error(result_list.error)
        end
      end
    end

    wrap_context 'when initialized with passing results' do
      it 'should return a passing result' do
        expect(result_list.to_cuprum_result)
          .to be_a_passing_result
          .with_value(result_list.value)
          .and_error(result_list.error)
      end

      wrap_context 'when initialized with value: an Object' do
        it 'should return a passing result' do
          expect(result_list.to_cuprum_result)
            .to be_a_passing_result
            .with_value(result_list.value)
            .and_error(result_list.error)
        end
      end
    end

    wrap_context 'when initialized with mixed results' do
      it 'should return a failing result' do
        expect(result_list.to_cuprum_result)
          .to be_a_failing_result
          .with_value(result_list.value)
          .and_error(result_list.error)
      end

      wrap_context 'when initialized with value: an Object' do
        it 'should return a passing result' do
          expect(result_list.to_cuprum_result)
            .to be_a_failing_result
            .with_value(result_list.value)
            .and_error(result_list.error)
        end
      end
    end
    # rubocop:enable RSpec/RepeatedExampleGroupBody

    wrap_context 'when initialized with allow_partial: true' do
      wrap_context 'when initialized with failing results' do
        it 'should return a failing result' do
          expect(result_list.to_cuprum_result)
            .to be_a_failing_result
            .with_value(result_list.value)
            .and_error(result_list.error)
        end
      end

      # rubocop:disable RSpec/RepeatedExampleGroupBody
      wrap_context 'when initialized with passing results' do
        it 'should return a passing result' do
          expect(result_list.to_cuprum_result)
            .to be_a_passing_result
            .with_value(result_list.value)
            .and_error(result_list.error)
        end
      end

      wrap_context 'when initialized with mixed results' do
        it 'should return a passing result' do
          expect(result_list.to_cuprum_result)
            .to be_a_passing_result
            .with_value(result_list.value)
            .and_error(result_list.error)
        end
      end
      # rubocop:enable RSpec/RepeatedExampleGroupBody
    end
  end

  describe '#value' do
    include_examples 'should define reader', :value, []

    wrap_context 'when initialized with value: an Object' do
      it { expect(result_list.value).to be == value }
    end

    # rubocop:disable RSpec/RepeatedExampleGroupBody
    wrap_context 'when initialized with failing results' do
      it { expect(result_list.value).to be == results.map(&:value) }

      wrap_context 'when initialized with value: an Object' do
        it { expect(result_list.value).to be == value }
      end
    end

    wrap_context 'when initialized with passing results' do
      it { expect(result_list.value).to be == results.map(&:value) }

      wrap_context 'when initialized with value: an Object' do
        it { expect(result_list.value).to be == value }
      end
    end

    wrap_context 'when initialized with mixed results' do
      it { expect(result_list.value).to be == results.map(&:value) }

      wrap_context 'when initialized with value: an Object' do
        it { expect(result_list.value).to be == value }
      end
    end
    # rubocop:enable RSpec/RepeatedExampleGroupBody
  end

  describe '#values' do
    include_examples 'should define reader', :values, []

    wrap_context 'when initialized with value: an Object' do
      it { expect(result_list.values).to be == [] }
    end

    # rubocop:disable RSpec/RepeatedExampleGroupBody
    wrap_context 'when initialized with failing results' do
      it { expect(result_list.values).to be == results.map(&:value) }

      wrap_context 'when initialized with value: an Object' do
        it { expect(result_list.values).to be == results.map(&:value) }
      end
    end

    wrap_context 'when initialized with passing results' do
      it { expect(result_list.values).to be == results.map(&:value) }

      wrap_context 'when initialized with value: an Object' do
        it { expect(result_list.values).to be == results.map(&:value) }
      end
    end

    wrap_context 'when initialized with mixed results' do
      it { expect(result_list.values).to be == results.map(&:value) }

      wrap_context 'when initialized with value: an Object' do
        it { expect(result_list.values).to be == results.map(&:value) }
      end
    end
    # rubocop:enable RSpec/RepeatedExampleGroupBody
  end
end
