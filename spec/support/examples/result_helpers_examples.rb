# frozen_string_literal: true

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

require 'cuprum/error'

module Spec::Examples
  module ResultHelpersExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_examples 'should implement the ResultHelpers interface' do
      describe '#build_result' do
        it 'should define the method' do
          expect(instance)
            .to respond_to(:build_result, true)
            .with(0).arguments
            .and_keywords(:error, :status, :value)
        end
      end

      describe '#failure' do
        it 'should define the method' do
          expect(instance).to respond_to(:failure, true).with(1).argument
        end
      end

      describe '#success' do
        it 'should define the method' do
          expect(instance).to respond_to(:success, true).with(1).argument
        end
      end
    end

    shared_examples 'should implement the ResultHelpers methods' do
      describe '#build_result' do
        let(:value) { 'returned value' }
        let(:error) { Cuprum::Error.new(message: 'Something went wrong.') }

        it 'should define the private method' do
          expect(instance).not_to respond_to(:build_result)

          expect(instance)
            .to respond_to(:build_result, true)
            .with(0).arguments
            .and_keywords(:error, :status, :value)
        end

        describe 'with no keywords' do
          let(:result) { instance.send(:build_result) }

          it { expect(result).to be_a Cuprum::Result }

          it { expect(result.error).to be nil }

          it { expect(result.status).to be :success }

          it { expect(result.value).to be nil }

          it 'should return a new object each time it is called' do
            result = instance.send(:build_result)

            expect(instance.send :build_result)
              .not_to be result
          end
        end

        describe 'with error: an error' do
          let(:result) { instance.send(:build_result, error: error) }

          it { expect(result).to be_a Cuprum::Result }

          it { expect(result.error).to be error }

          it { expect(result.status).to be :failure }

          it { expect(result.value).to be nil }

          it 'should return a new object each time it is called' do
            result = instance.send(:build_result, error: error)

            expect(instance.send :build_result, error: error)
              .not_to be result
          end
        end

        describe 'with error: an error and status: :failure' do
          let(:result) do
            instance.send(:build_result, error: error, status: :failure)
          end

          it { expect(result).to be_a Cuprum::Result }

          it { expect(result.error).to be error }

          it { expect(result.status).to be :failure }

          it { expect(result.value).to be nil }

          it 'should return a new object each time it is called' do
            result =
              instance.send(:build_result, error: error, status: :failure)

            expect(instance.send :build_result, error: error, status: :failure)
              .not_to be result
          end
        end

        describe 'with error: an error and status: :success' do
          let(:result) do
            instance.send(:build_result, error: error, status: :success)
          end

          it { expect(result).to be_a Cuprum::Result }

          it { expect(result.error).to be error }

          it { expect(result.status).to be :success }

          it { expect(result.value).to be nil }

          it 'should return a new object each time it is called' do
            result =
              instance.send(:build_result, error: error, status: :success)

            expect(instance.send :build_result, error: error, status: :success)
              .not_to be result
          end
        end

        describe 'with error: an error and value: a value' do
          let(:result) do
            instance.send(:build_result, error: error, value: value)
          end

          it { expect(result).to be_a Cuprum::Result }

          it { expect(result.error).to be error }

          it { expect(result.status).to be :failure }

          it { expect(result.value).to be value }

          it 'should return a new object each time it is called' do
            result =
              instance.send(:build_result, error: error, value: value)

            expect(instance.send :build_result, error: error, value: value)
              .not_to be result
          end
        end

        describe 'with status: :failure' do
          let(:result) { instance.send(:build_result, status: :failure) }

          it { expect(result).to be_a Cuprum::Result }

          it { expect(result.error).to be nil }

          it { expect(result.status).to be :failure }

          it { expect(result.value).to be nil }

          it 'should return a new object each time it is called' do
            result = instance.send(:build_result, status: :failure)

            expect(instance.send :build_result, status: :failure)
              .not_to be result
          end
        end

        describe 'with status: :failure and value: a value' do
          let(:result) do
            instance.send(:build_result, status: :failure, value: value)
          end

          it { expect(result).to be_a Cuprum::Result }

          it { expect(result.error).to be nil }

          it { expect(result.status).to be :failure }

          it { expect(result.value).to be value }

          it 'should return a new object each time it is called' do
            result =
              instance.send(:build_result, status: :failure, value: value)

            expect(instance.send :build_result, status: :failure, value: value)
              .not_to be result
          end
        end

        describe 'with status: :success' do
          let(:result) { instance.send(:build_result, status: :success) }

          it { expect(result).to be_a Cuprum::Result }

          it { expect(result.error).to be nil }

          it { expect(result.status).to be :success }

          it { expect(result.value).to be nil }

          it 'should return a new object each time it is called' do
            result = instance.send(:build_result, status: :success)

            expect(instance.send :build_result, status: :success)
              .not_to be result
          end
        end

        describe 'with status: :success and value: a value' do
          let(:result) do
            instance.send(:build_result, status: :success, value: value)
          end

          it { expect(result).to be_a Cuprum::Result }

          it { expect(result.error).to be nil }

          it { expect(result.status).to be :success }

          it { expect(result.value).to be value }

          it 'should return a new object each time it is called' do
            result =
              instance.send(:build_result, status: :success, value: value)

            expect(instance.send :build_result, status: :success, value: value)
              .not_to be result
          end
        end

        describe 'with value: a value' do
          let(:result) { instance.send(:build_result, value: value) }

          it { expect(result).to be_a Cuprum::Result }

          it { expect(result.error).to be nil }

          it { expect(result.status).to be :success }

          it { expect(result.value).to be value }

          it 'should return a new object each time it is called' do
            result = instance.send(:build_result, value: value)

            expect(instance.send :build_result, value: value)
              .not_to be result
          end
        end

        describe 'with an error, status: :failure, and a value' do
          let(:result) do
            instance.send(
              :build_result,
              error:  error,
              status: :failure,
              value:  value
            )
          end

          it { expect(result).to be_a Cuprum::Result }

          it { expect(result.error).to be error }

          it { expect(result.status).to be :failure }

          it { expect(result.value).to be value }

          it 'should return a new object each time it is called' do
            result =
              instance.send(:build_result, status: :failure, value: value)

            expect(instance.send :build_result, status: :failure, value: value)
              .not_to be result
          end
        end

        describe 'with an error, status: :success, and a value' do
          let(:result) do
            instance.send(
              :build_result,
              error:  error,
              status: :success,
              value:  value
            )
          end

          it { expect(result).to be_a Cuprum::Result }

          it { expect(result.error).to be error }

          it { expect(result.status).to be :success }

          it { expect(result.value).to be value }

          it 'should return a new object each time it is called' do
            result =
              instance.send(:build_result, status: :success, value: value)

            expect(instance.send :build_result, status: :success, value: value)
              .not_to be result
          end
        end
      end

      describe '#failure' do
        let(:error) { Cuprum::Error.new(message: 'Something went wrong.') }

        it 'should define the private method' do
          expect(instance).not_to respond_to(:failure)

          expect(instance).to respond_to(:failure, true).with(1).argument
        end

        it 'should delegate to #build_result' do
          allow(instance).to receive(:build_result)

          instance.send(:failure, error)

          expect(instance).to have_received(:build_result).with(error: error)
        end

        it 'should return a failing result', :aggregate_failures do
          result = instance.send(:failure, error)

          expect(result).to be_a Cuprum::Result
          expect(result.status).to be :failure
          expect(result.value).to be nil
          expect(result.error).to be error
        end
      end

      describe '#success' do
        let(:value) { 'result value' }

        it 'should define the private method' do
          expect(instance).not_to respond_to(:success)

          expect(instance).to respond_to(:success, true).with(1).argument
        end

        it 'should delegate to #build_result' do
          allow(instance).to receive(:build_result)

          instance.send(:success, value)

          expect(instance).to have_received(:build_result).with(value: value)
        end

        it 'should return a passing result', :aggregate_failures do
          result = instance.send(:success, value)

          expect(result).to be_a Cuprum::Result
          expect(result.status).to be :success
          expect(result.value).to be value
          expect(result.error).to be nil
        end
      end
    end
  end
end
