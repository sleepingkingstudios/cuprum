# frozen_string_literal: true

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

require 'cuprum/error'

module Spec::Examples
  module ProcessingExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_context 'when a custom result class is defined' do
      options = { base_class: Struct.new(:value, :error) }
      example_class 'Spec::CustomResult', options do |klass|
        klass.send(
          :define_method,
          :success?,
          -> { error.nil? }
        )

        klass.send(
          :define_method,
          :failure?,
          -> { !success? }
        )

        klass.send(
          :define_method,
          :to_cuprum_result,
          -> { self }
        )
      end
    end

    shared_examples 'should implement the Processing interface' do
      describe '#arity' do
        include_examples 'should have reader', :arity
      end

      describe '#call' do
        it 'should define the method' do
          expect(command)
            .to respond_to(:call)
            .with_unlimited_arguments
            .and_a_block
        end
      end
    end

    shared_examples 'should implement the Processing methods' do
      describe '#arity' do
        it { expect(command.arity).to be == command.method(:process).arity }
      end
    end

    shared_examples 'should execute the command implementation' do
      it 'should return a failing result', :aggregate_failures do
        result = command.call.to_cuprum_result
        error  = result.error

        expect(result.failure?).to be true
        expect(result.value).to be nil

        expect(error).to be_a Cuprum::Errors::CommandNotImplemented
        expect(error.command).to be command
      end

      context 'when the implementation does not support the given arguments' \
      do
        include_context 'when the implementation is defined'

        let(:implementation) { -> {} }
        let(:arguments)      { %i[ichi ni san] }

        it 'should raise an error' do
          expect { command.call(*arguments) }
            .to raise_error ArgumentError,
              'wrong number of arguments (given 3, expected 0)'
        end
      end

      context 'when the implementation supports the given arguments' do
        include_context 'when the implementation is defined'

        let(:arguments) { %i[ichi ni san] }
        let(:keywords)  { { yon: 4, go: 5 } }
        let(:called_arguments) do
          []
        end
        let(:implementation) do
          called = called_arguments

          lambda do |*args, &block|
            called.concat(args)

            block&.call
          end
        end

        it 'should forward all arguments to the implementation',
          :aggregate_failures \
        do
          yielded = false

          command.call(*arguments, **keywords, &-> { yielded = true })

          expect(called_arguments).to be == [*arguments, keywords]
          expect(yielded).to be true
        end
      end

      wrap_context 'when the implementation is defined' do
        let(:result_class)   { defined?(super()) ? super() : Cuprum::Result }
        let(:expected_class) { defined?(super()) ? super() : result_class }

        shared_examples 'should return an empty result' do
          it { expect(command.call).to be_a expected_class }

          it { expect(command.call.value).to be nil }

          it { expect(command.call.error).to be nil }

          it { expect(command.call.success?).to be true }

          it { expect(command.call.failure?).to be false }
        end

        shared_examples 'should return a result with the expected value' do
          it { expect(command.call).to be_a expected_class }

          it { expect(command.call.value).to be value }

          it { expect(command.call.error).to be nil }

          it { expect(command.call.success?).to be true }

          it { expect(command.call.failure?).to be false }
        end

        shared_examples 'should return a result with the expected error' do
          it { expect(command.call).to be_a expected_class }

          it { expect(command.call.value).to be value }

          it { expect(command.call.error).to be expected_error }

          it { expect(command.call.success?).to be false }

          it { expect(command.call.failure?).to be true }
        end

        let(:value) { nil }

        include_examples 'should return an empty result'

        context 'when the implementation returns a value' do
          let(:value) { 'returned value' }
          let(:implementation) do
            returned = value

            -> { returned }
          end

          include_examples 'should return a result with the expected value'
        end

        context 'when the implementation returns an empty result' do
          let(:result) { Cuprum::Result.new }
          let(:implementation) do
            returned = result

            -> { returned }
          end

          include_examples 'should return an empty result'
        end

        context 'when the implementation returns a result with a value' do
          let(:value)  { 'returned value' }
          let(:result) { Cuprum::Result.new(value: value) }
          let(:implementation) do
            returned = result

            -> { returned }
          end

          include_examples 'should return a result with the expected value'
        end

        context 'when the implementation returns a result with an error' do
          let(:expected_error) do
            Cuprum::Error.new(message: 'Something went wrong.')
          end
          let(:result) do
            Cuprum::Result.new(error: expected_error)
          end
          let(:implementation) do
            returned = result

            -> { returned }
          end

          include_examples 'should return a result with the expected error'
        end

        context 'when the implementation calls #failure' do
          let(:expected_error) do
            Cuprum::Error.new(message: 'Something went wrong.')
          end
          let(:implementation) do
            err = expected_error

            -> { failure(err) }
          end

          include_examples 'should return a result with the expected error'
        end

        context 'when the implementation calls #success' do
          let(:value) { 'returned value' }
          let(:implementation) do
            val = value

            -> { success(val) }
          end

          include_examples 'should return a result with the expected value'
        end

        context 'when the implementation returns a result-like object' do
          include_context 'when a custom result class is defined'

          let(:result)       { Spec::CustomResult.new(nil) }
          let(:result_class) { Spec::CustomResult }
          let(:implementation) do
            returned = result

            -> { returned }
          end

          include_examples 'should return an empty result'
        end

        context 'when the implementation returns a result-like object with ' \
                 'a value' \
        do
          include_context 'when a custom result class is defined'

          let(:value)  { 'returned value' }
          let(:result) { Spec::CustomResult.new(value) }

          it { expect(result.to_cuprum_result).to be_a Spec::CustomResult }

          it { expect(result.value).to be value }

          it { expect(result.error).to be nil }

          it { expect(result.success?).to be true }
        end

        context 'when the implementation returns a result-like object with ' \
                 'an error' \
        do
          include_context 'when a custom result class is defined'

          let(:expected_errors) { ['errors.messages.unknown'] }
          let(:result)          { Spec::CustomResult.new(nil, expected_errors) }

          it { expect(result.to_cuprum_result).to be_a Spec::CustomResult }

          it { expect(result.value).to be nil }

          it { expect(result.error).to be == expected_errors }

          it { expect(result.success?).to be false }
        end

        context 'when the implementation calls itself' do
          let(:implementation) do
            lambda do |int|
              return 0 if int < 1

              return 1 if int == 1

              call(int - 1).value + call(int - 2).value
            end
          end

          it 'should return a result', :aggregate_failures do
            result = command.call(10)

            expect(result).to be_a expected_class
            expect(result.value).to be 55
            expect(result.error).to be nil
          end
        end

        context 'when a custom result object is returned' do
          include_context 'when a custom result class is defined'

          let(:error) do
            Cuprum::Error.new(message: 'Something went wrong.')
          end
          let(:custom_result) { Spec::CustomResult.new(value, error) }

          before(:example) do
            allow(command).to receive(:process).and_return(value)
            allow(command)
              .to receive(:build_result)
              .and_return(custom_result)
          end

          it { expect(command.call.to_cuprum_result).to be custom_result }

          it { expect(command.call.to_cuprum_result.value).to be value }

          it { expect(command.call.to_cuprum_result.error).to be error }
        end
      end
    end
  end
end
