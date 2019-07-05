require 'rspec/sleeping_king_studios/concerns/shared_example_group'

module Spec::Examples
  module OperationExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_context 'when the operation has been called' do
      let(:value) { 'returned value'.freeze }

      def call_operation
        call_method = instance.method(:call)

        instance.call(*generate_arguments(call_method))
      end # method call_operation

      def generate_arguments method
        params    = method.parameters
        count     = params.select { |(type, _)| type == :req }.count
        keys      =
          params.select { |(type, _)| type == :keyreq }.map { |(_, key)| key }
        arguments = Array.new(count)
        keywords  = Hash[keys.map { |key| [key, nil] }]

        keywords.empty? ? arguments : arguments << keywords
      end # method generate_arguments

      before(:example) do
        allow(instance).to receive(:process).and_return(value)
      end # before example
    end # shared_context

    shared_context 'when the result has errors' do
      let(:value)  { 'returned value'.freeze }
      let(:errors) { ['errors.messages.unknown'] }
      let(:result) { Cuprum::Result.new(value: value, :errors => errors) }

      before(:example) do
        allow(instance).to receive(:result).and_return(result)
      end # before example
    end # shared_context

    shared_context 'when the result has a value' do
      let(:value)  { 'returned value'.freeze }
      let(:result) { Cuprum::Result.new(value: value) }

      before(:example) do
        allow(instance).to receive(:result).and_return(result)
      end # before example
    end # shared_context

    shared_examples 'should implement the Operation methods' do
      describe '#call' do
        wrap_context 'when the operation has been called' do
          it 'should return the operation' do
            expect(call_operation).to be instance
          end # it
        end # it
      end # describe

      describe '#called?' do
        include_examples 'should have predicate', :called?, false

        wrap_context 'when the operation has been called' do
          before(:example) { call_operation }

          it { expect(instance.called?).to be true }
        end # wrap_context
      end # describe

      describe '#errors' do
        include_examples 'should have reader', :errors, nil

        wrap_context 'when the result has a value' do
          it { expect(instance.errors).to be nil }
        end # wrap_context

        wrap_context 'when the result has errors' do
          it { expect(instance.errors).to be == errors }
        end # wrap_context
      end # describe

      describe '#failure?' do
        include_examples 'should have predicate', :failure?, false

        wrap_context 'when the result has a value' do
          it { expect(instance.failure?).to be false }
        end # wrap_context

        wrap_context 'when the result has errors' do
          it { expect(instance.failure?).to be true }
        end # wrap_context
      end # describe

      describe '#reset!' do
        it { expect(instance).to respond_to(:reset!).with(0).arguments }

        wrap_context 'when the operation has been called' do
          before(:example) { call_operation }

          it 'should clear the result' do
            expect { instance.reset! }.to change(instance, :result).to be nil
          end # it

          it 'should mark the operation as not called' do
            expect { instance.reset! }.to change(instance, :called?).to be false
          end # it
        end # wrap_context
      end # describe

      describe '#result' do
        include_examples 'should have reader', :result, nil

        wrap_context 'when the operation has been called' do
          it 'should return the result' do
            call_operation

            result = instance.result
            expect(result).to be_a Cuprum::Result
            expect(result.value).to be value
          end # it
        end # wrap_context
      end # describe

      describe '#success?' do
        include_examples 'should have predicate', :success?, false

        wrap_context 'when the result has a value' do
          it { expect(instance.success?).to be true }
        end # wrap_context

        wrap_context 'when the result has errors' do
          it { expect(instance.success?).to be false }
        end # wrap_context
      end # describe

      describe '#to_cuprum_result' do
        it 'should return an OperationNotCalled error', :aggregate_failures do
          result = instance.to_cuprum_result
          error  = result.errors

          expect(result).to be_a Cuprum::Result
          expect(result.failure?).to be true
          expect(result.value).to be nil

          expect(error).to be_a Cuprum::Errors::OperationNotCalled
          expect(error.operation).to be instance
        end

        wrap_context 'when the operation has been called' do
          it 'should return the result' do
            call_operation

            result = instance.to_cuprum_result
            expect(result).to be_a Cuprum::Result
            expect(result.value).to be value
          end # it
        end # wrap_context
      end # describe

      describe '#value' do
        include_examples 'should have reader', :value, nil

        wrap_context 'when the result has a value' do
          it { expect(instance.value).to be value }
        end # wrap_context

        wrap_context 'when the result has errors' do
          it { expect(instance.value).to be value }
        end # wrap_context
      end # describe
    end # shared_examples
  end # module
end # module
