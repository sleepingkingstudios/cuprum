# frozen_string_literal: true

require 'forwardable'

require 'cuprum/error'
require 'cuprum/result'

require 'support/examples/result_examples'
require 'support/results/halting_result'

RSpec.describe Cuprum::Result do # rubocop:disable RSpec/SpecFilePathFormat
  include Spec::Examples::ResultExamples

  context 'with a subclass with custom statuses' do
    shared_context 'when the result has status: :halted' do
      before(:example) { params[:status] = :halted }
    end

    subject(:result) { described_class.new(**params) }

    let(:described_class) { Spec::Results::HaltingResult }
    let(:params) { {} }

    describe '::new' do
      it 'should define the constructor' do
        expect(described_class)
          .to be_constructible
          .with(0).arguments
          .and_keywords(:error, :status, :value)
      end

      describe 'with status: :failure' do
        let(:result) { described_class.new(status: :failure) }

        it { expect(result.status).to be :failure }
      end

      describe 'with status: "failure"' do
        let(:result) { described_class.new(status: 'failure') }

        it { expect(result.status).to be :failure }
      end

      describe 'with status: :halted' do
        let(:result) { described_class.new(status: :halted) }

        it { expect(result.status).to be :halted }
      end

      describe 'with status: "halted"' do
        let(:result) { described_class.new(status: 'halted') }

        it { expect(result.status).to be :halted }
      end

      describe 'with status: :success' do
        let(:result) { described_class.new(status: :success) }

        it { expect(result.status).to be :success }
      end

      describe 'with status: "success"' do
        let(:result) { described_class.new(status: 'success') }

        it { expect(result.status).to be :success }
      end

      describe 'with status: invalid object' do
        let(:status)        { Object.new.freeze }
        let(:error_message) { "invalid status #{status.inspect}" }

        it 'should raise an error' do
          expect { described_class.new(status:) }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with status: invalid value' do
        let(:status)        { :invalid }
        let(:error_message) { "invalid status #{status.inspect}" }

        it 'should raise an error' do
          expect { described_class.new(status:) }
            .to raise_error ArgumentError, error_message
        end
      end
    end

    describe '#==' do
      include Spec::Examples::ResultExamples::EqualityExamples

      value_scenarios = {
        'a nil value'          => nil,
        'a non-matching value' => 'other value'
      }
      error_scenarios = {
        'a nil error'          => nil,
        'a non-matching error' => Cuprum::Error.new(
          message: 'Other error message.'
        )
      }
      status_scenarios = {
        ''                 => nil,
        'status: :failure' => :failure,
        'status: :halted'  => :halted,
        'status: :success' => :success
      }
      default_scenarios = {
        value:  value_scenarios,
        error:  error_scenarios,
        status: status_scenarios
      }

      describe 'with nil' do
        # rubocop:disable Style/NilComparison
        it { expect(result == nil).to be false }
        # rubocop:enable Style/NilComparison
      end

      include_examples 'should compare the results in each scenario',
        default_scenarios

      wrap_context 'when the result has a value' do
        all_scenarios = {
          value:  value_scenarios.merge('a matching value' => 'returned value'),
          error:  error_scenarios,
          status: status_scenarios.merge('status: :halted' => :halted)
        }

        include_examples 'should compare the results in each scenario',
          all_scenarios

        # rubocop:disable RSpec/RepeatedExampleGroupBody
        wrap_context 'when the result has status: :failure' do
          include_examples 'should compare the results in each scenario',
            all_scenarios
        end

        wrap_context 'when the result has status: :halted' do
          include_examples 'should compare the results in each scenario',
            all_scenarios
        end

        wrap_context 'when the result has status: :success' do
          include_examples 'should compare the results in each scenario',
            all_scenarios
        end
        # rubocop:enable RSpec/RepeatedExampleGroupBody
      end

      wrap_context 'when the result has an error' do
        all_scenarios = {
          value:  value_scenarios,
          error:  error_scenarios.merge(
            'a matching error' => Cuprum::Error.new(
              message: 'Something went wrong.'
            )
          ),
          status: status_scenarios.merge('status: :halted' => :halted)
        }

        include_examples 'should compare the results in each scenario',
          all_scenarios

        # rubocop:disable RSpec/RepeatedExampleGroupBody
        wrap_context 'when the result has status: :failure' do
          include_examples 'should compare the results in each scenario',
            all_scenarios
        end

        wrap_context 'when the result has status: :halted' do
          include_examples 'should compare the results in each scenario',
            all_scenarios
        end

        wrap_context 'when the result has status: :success' do
          include_examples 'should compare the results in each scenario',
            all_scenarios
        end
        # rubocop:enable RSpec/RepeatedExampleGroupBody
      end

      context 'when the result has a value and an error' do
        include_context 'when the result has a value'
        include_context 'when the result has an error'

        all_scenarios = {
          value:  value_scenarios.merge('a matching value' => 'returned value'),
          error:  error_scenarios.merge(
            'a matching error' => Cuprum::Error.new(
              message: 'Something went wrong.'
            )
          ),
          status: status_scenarios
        }

        include_examples 'should compare the results in each scenario',
          all_scenarios

        # rubocop:disable RSpec/RepeatedExampleGroupBody
        wrap_context 'when the result has status: :failure' do
          include_examples 'should compare the results in each scenario',
            all_scenarios
        end

        wrap_context 'when the result has status: :halted' do
          include_examples 'should compare the results in each scenario',
            all_scenarios
        end

        wrap_context 'when the result has status: :success' do
          include_examples 'should compare the results in each scenario',
            all_scenarios
        end
        # rubocop:enable RSpec/RepeatedExampleGroupBody
      end

      # rubocop:disable RSpec/RepeatedExampleGroupBody
      wrap_context 'when the result has status: :failure' do
        include_examples 'should compare the results in each scenario',
          default_scenarios
      end

      wrap_context 'when the result has status: :halted' do
        include_examples 'should compare the results in each scenario',
          default_scenarios
      end

      wrap_context 'when the result has status: :success' do
        include_examples 'should compare the results in each scenario',
          default_scenarios
      end
      # rubocop:enable RSpec/RepeatedExampleGroupBody
    end

    describe '#failure?' do
      include_examples 'should have predicate', :failure?, false

      wrap_context 'when the result has an error' do
        it { expect(result.failure?).to be true }

        wrap_context 'when the result has status: :failure' do
          it { expect(result.failure?).to be true }
        end

        # rubocop:disable RSpec/RepeatedExampleGroupBody
        wrap_context 'when the result has status: :halted' do
          it { expect(result.failure?).to be false }
        end

        wrap_context 'when the result has status: :success' do
          it { expect(result.failure?).to be false }
        end
        # rubocop:enable RSpec/RepeatedExampleGroupBody
      end

      wrap_context 'when the result has status: :failure' do
        it { expect(result.failure?).to be true }
      end

      # rubocop:disable RSpec/RepeatedExampleGroupBody
      wrap_context 'when the result has status: :halted' do
        it { expect(result.failure?).to be false }
      end

      wrap_context 'when the result has status: :success' do
        it { expect(result.failure?).to be false }
      end
      # rubocop:enable RSpec/RepeatedExampleGroupBody
    end

    describe '#halted?' do
      include_examples 'should have predicate', :halted?, false

      wrap_context 'when the result has an error' do
        it { expect(result.halted?).to be false }

        # rubocop:disable RSpec/RepeatedExampleGroupBody
        wrap_context 'when the result has status: :failure' do
          it { expect(result.halted?).to be false }
        end

        wrap_context 'when the result has status: :halted' do
          it { expect(result.halted?).to be true }
        end

        wrap_context 'when the result has status: :success' do
          it { expect(result.halted?).to be false }
        end
        # rubocop:enable RSpec/RepeatedExampleGroupBody
      end

      # rubocop:disable RSpec/RepeatedExampleGroupBody
      wrap_context 'when the result has status: :failure' do
        it { expect(result.halted?).to be false }
      end

      wrap_context 'when the result has status: :halted' do
        it { expect(result.halted?).to be true }
      end

      wrap_context 'when the result has status: :success' do
        it { expect(result.halted?).to be false }
      end
      # rubocop:enable RSpec/RepeatedExampleGroupBody
    end

    describe '#success?' do
      include_examples 'should have predicate', :success?, true

      wrap_context 'when the result has an error' do
        it { expect(result.success?).to be false }

        # rubocop:disable RSpec/RepeatedExampleGroupBody
        wrap_context 'when the result has status: :failure' do
          it { expect(result.success?).to be false }
        end

        wrap_context 'when the result has status: :halted' do
          it { expect(result.success?).to be false }
        end
        # rubocop:enable RSpec/RepeatedExampleGroupBody

        wrap_context 'when the result has status: :success' do
          it { expect(result.success?).to be true }
        end
      end

      # rubocop:disable RSpec/RepeatedExampleGroupBody
      wrap_context 'when the result has status: :failure' do
        it { expect(result.success?).to be false }
      end

      wrap_context 'when the result has status: :halted' do
        it { expect(result.success?).to be false }
      end
      # rubocop:enable RSpec/RepeatedExampleGroupBody

      wrap_context 'when the result has status: :success' do
        it { expect(result.success?).to be true }
      end
    end
  end
end
