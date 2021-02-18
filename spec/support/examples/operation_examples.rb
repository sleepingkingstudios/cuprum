# frozen_string_literal: true

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

module Spec::Examples
  module OperationExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_context 'when the operation has been called' do
      let(:value) { 'returned value' }

      def call_operation
        call_method = operation.method(:call)

        operation.call(*generate_arguments(call_method))
      end

      def generate_arguments(method)
        params    = method.parameters
        count     = params.select { |(type, _)| type == :req }.count
        keys      =
          params.select { |(type, _)| type == :keyreq }.map { |(_, key)| key }
        arguments = Array.new(count)
        keywords  = keys.map { |key| [key, nil] }.to_h

        keywords.empty? ? arguments : arguments << keywords
      end

      before(:example) do
        allow(operation).to receive(:process).and_return(value)
      end
    end

    shared_context 'when the result has an error' do
      let(:value)  { 'returned value' }
      let(:error)  { Cuprum::Error.new(message: 'Something went wrong.') }
      let(:result) { Cuprum::Result.new(value: value, error: error) }

      before(:example) do
        allow(operation).to receive(:result).and_return(result)
      end
    end

    shared_context 'when the result has a value' do
      let(:value)  { 'returned value' }
      let(:result) { Cuprum::Result.new(value: value) }

      before(:example) do
        allow(operation).to receive(:result).and_return(result)
      end
    end

    shared_context 'when the result has status: :failure' do
      let(:result) { Cuprum::Result.new(status: :failure) }

      before(:example) do
        allow(operation).to receive(:result).and_return(result)
      end
    end

    shared_context 'when the result has status: :success' do
      let(:result) { Cuprum::Result.new(status: :success) }

      before(:example) do
        allow(operation).to receive(:result).and_return(result)
      end
    end

    shared_examples 'should implement the Operation methods' do
      describe '#call' do
        wrap_context 'when the operation has been called' do
          it 'should return the operation' do
            expect(call_operation).to be operation
          end
        end
      end

      describe '#called?' do
        include_examples 'should have predicate', :called?, false

        wrap_context 'when the operation has been called' do
          before(:example) { call_operation }

          it { expect(operation.called?).to be true }
        end
      end

      describe '#error' do
        include_examples 'should have reader', :error, nil

        wrap_context 'when the result has a value' do
          it { expect(operation.error).to be nil }
        end

        wrap_context 'when the result has an error' do
          it { expect(operation.error).to be == error }
        end
      end

      describe '#failure?' do
        include_examples 'should have predicate', :failure?, false

        wrap_context 'when the result has a value' do
          it { expect(operation.failure?).to be false }
        end

        wrap_context 'when the result has an error' do
          it { expect(operation.failure?).to be true }
        end

        wrap_context 'when the result has status: :failure' do
          it { expect(operation.failure?).to be true }
        end

        wrap_context 'when the result has status: :success' do
          it { expect(operation.failure?).to be false }
        end
      end

      describe '#reset!' do
        it { expect(operation).to respond_to(:reset!).with(0).arguments }

        wrap_context 'when the operation has been called' do
          before(:example) { call_operation }

          it 'should clear the result' do
            expect { operation.reset! }.to change(operation, :result).to be nil
          end

          it 'should mark the operation as not called' do
            expect { operation.reset! }
              .to change(operation, :called?)
              .to be false
          end
        end
      end

      describe '#result' do
        include_examples 'should have reader', :result, nil

        wrap_context 'when the operation has been called' do
          it { expect(call_operation.result).to be_a Cuprum::Result }

          it { expect(call_operation.result.value).to be value }
        end
      end

      describe '#status' do
        include_examples 'should have reader', :status, nil

        wrap_context 'when the result has a value' do
          it { expect(operation.status).to be :success }
        end

        wrap_context 'when the result has an error' do
          it { expect(operation.status).to be :failure }
        end

        wrap_context 'when the result has status: :failure' do
          it { expect(operation.status).to be :failure }
        end

        wrap_context 'when the result has status: :success' do
          it { expect(operation.status).to be :success }
        end
      end

      describe '#success?' do
        include_examples 'should have predicate', :success?, false

        wrap_context 'when the result has a value' do
          it { expect(operation.success?).to be true }
        end

        wrap_context 'when the result has an error' do
          it { expect(operation.success?).to be false }
        end

        wrap_context 'when the result has status: :failure' do
          it { expect(operation.success?).to be false }
        end

        wrap_context 'when the result has status: :success' do
          it { expect(operation.success?).to be true }
        end
      end

      describe '#to_cuprum_result' do
        it 'should return an OperationNotCalled error', :aggregate_failures do
          result = operation.to_cuprum_result
          error  = result.error

          expect(result).to be_a Cuprum::Result
          expect(result.failure?).to be true
          expect(result.value).to be nil

          expect(error).to be_a Cuprum::Errors::OperationNotCalled
          expect(error.operation).to be operation
        end

        wrap_context 'when the operation has been called' do
          it { expect(call_operation.to_cuprum_result).to be_a Cuprum::Result }

          it { expect(call_operation.to_cuprum_result.value).to be value }
        end
      end

      describe '#value' do
        include_examples 'should have reader', :value, nil

        wrap_context 'when the result has a value' do
          it { expect(operation.value).to be value }
        end

        wrap_context 'when the result has an error' do
          it { expect(operation.value).to be value }
        end
      end
    end
  end
end
