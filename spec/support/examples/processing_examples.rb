# frozen_string_literal: true

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

module Spec::Examples
  module ProcessingExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_context 'when a custom result class is defined' do
      options = { base_class: Struct.new(:value, :errors) }
      example_class 'Spec::CustomResult', options do |klass|
        klass.send(
          :define_method,
          :success?,
          ->() { errors.nil? || errors.empty? }
        )

        klass.send(
          :define_method,
          :failure?,
          ->() { !success? }
        )

        klass.send(
          :define_method,
          :to_cuprum_result,
          ->() { self }
        )
      end
    end

    shared_examples 'should implement the Processing interface' do
      describe '#arity' do
        include_examples 'should have reader',
          :arity,
          ->() { instance.method(:process).arity }
      end

      describe '#call' do
        it 'should define the method' do
          expect(instance)
            .to respond_to(:call)
            .with_unlimited_arguments
            .and_a_block
        end
      end
    end

    shared_examples 'should implement the Processing methods' do
      describe '#build_result' do
        include_context 'when a custom result class is defined'

        let(:value)  { 'returned value' }
        let(:errors) { [] }

        it 'should define the private method' do
          expect(instance).not_to respond_to(:build_result)

          expect(instance)
            .to respond_to(:build_result, true)
            .with(1).argument
            .and_keywords(:errors)
        end

        it 'should return a result' do
          result = instance.send(:build_result, value, errors: errors)

          expect(result).to be_a Cuprum::Result
          expect(result.value).to be value
          expect(result.errors).to be errors
        end

        it 'should return a new object each time it is called' do
          result = instance.send(:build_result, value, errors: errors)

          expect(instance.send :build_result, value, errors: errors)
            .not_to be result
        end

        context 'when a custom result object is returned' do
          let(:custom_result) { Spec::CustomResult.new(value, []) }

          before(:example) do
            allow(instance).to receive(:process).and_return(value)
            allow(instance)
              .to receive(:build_result)
              .and_return(custom_result)
          end

          it 'should return the custom result when called' do
            result = instance.call.to_cuprum_result

            expect(result).to be custom_result
            expect(result.value).to be value
          end
        end
      end

      describe '#result' do
        context 'when the #process method is executed' do
          it 'should return the current result' do
            result_during_process = nil

            allow(instance).to receive(:process) do
              result_during_process = instance.send(:result)

              nil
            end

            returned_result = instance.call.to_cuprum_result

            expect(result_during_process).to be_a Cuprum::Result
            expect(result_during_process).to be returned_result
          end
        end
      end
    end

    shared_examples 'should execute the command implementation' do
      it 'should return a failing result' do
        result = instance.call.to_cuprum_result
        error  = result.errors

        expect(result.failure?).to be true
        expect(result.value).to be nil

        expect(error).to be_a Cuprum::Errors::CommandNotImplemented
        expect(error.command).to be instance
      end

      context 'when the implementation does not support the given arguments' \
      do
        include_context 'when the implementation is defined'

        let(:implementation) { ->() {} }
        let(:arguments)      { %i[ichi ni san] }

        it 'should raise an error' do
          expect { instance.call(*arguments) }
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

        it 'should forward all arguments to the implementation' do
          yielded = false

          instance.call(*arguments, **keywords, &->() { yielded = true })

          expect(called_arguments).to be == [*arguments, keywords]
          expect(yielded).to be true
        end
      end

      wrap_context 'when the implementation is defined' do
        let(:result_class)   { defined?(super()) ? super() : Cuprum::Result }
        let(:expected_class) { defined?(super()) ? super() : result_class }

        shared_examples 'should return an empty result' do
          it 'should return a result' do
            result = instance.call

            expect(result).to be_a expected_class
            expect(result.value).to be nil
            expect(result.errors).to be nil
            expect(result.success?).to be true
            expect(result.failure?).to be false
          end
        end

        shared_examples 'should return a result with the expected value' do
          it 'should return a result with the expected value' do
            result = instance.call

            expect(result).to be_a expected_class
            expect(result.value).to be value
            expect(result.errors).to be nil
            expect(result.success?).to be true
            expect(result.failure?).to be false
          end
        end

        shared_examples 'should return a result with the expected errors' do
          it 'should return a result with the expected errors' do
            result = instance.call

            expect(result).to be_a expected_class
            expect(result.value).to be nil
            expect(result.errors).to be == expected_errors
            expect(result.success?).to be false
            expect(result.failure?).to be true
          end
        end

        let(:value) { nil }

        include_examples 'should return an empty result'

        context 'when the implementation returns a value' do
          let(:value) { 'returned value' }
          let(:implementation) do
            returned = value

            ->() { returned }
          end

          include_examples 'should return a result with the expected value'
        end

        context 'when the implementation sets the errors' do
          let(:expected_errors) { ['errors.messages.unknown'] }
          let(:implementation) do
            returned = value
            errors   = expected_errors

            lambda do
              Cuprum::Result.new(value: returned, errors: errors)
            end
          end

          include_examples 'should return a result with the expected errors'
        end

        context 'when the implementation returns the current result' do
          let(:implementation) do
            ->() { result }
          end

          include_examples 'should return an empty result'
        end

        context 'when the implementation returns an empty result' do
          let(:result) { Cuprum::Result.new }
          let(:implementation) do
            returned = result

            ->() { returned }
          end

          include_examples 'should return an empty result'
        end

        context 'when the implementation returns a result with a value' do
          let(:value)  { 'returned value' }
          let(:result) { Cuprum::Result.new(value: value) }
          let(:implementation) do
            returned = result

            ->() { returned }
          end

          include_examples 'should return a result with the expected value'
        end

        context 'when the implementation returns a result with errors' do
          let(:expected_errors) { ['errors.messages.unknown'] }
          let(:result) do
            Cuprum::Result.new(errors: expected_errors)
          end
          let(:implementation) do
            returned = result

            ->() { returned }
          end

          include_examples 'should return a result with the expected errors'
        end

        context 'when the implementation returns a result-like object' do
          include_context 'when a custom result class is defined'

          let(:result)       { Spec::CustomResult.new(nil) }
          let(:result_class) { Spec::CustomResult }
          let(:implementation) do
            returned = result

            ->() { returned }
          end

          include_examples 'should return an empty result'
        end

        context 'when the implementation returns a result-like object with ' \
                 'a value' \
        do
          include_context 'when a custom result class is defined'

          let(:value)  { 'returned value' }
          let(:result) { Spec::CustomResult.new(value) }
          let(:implementation) do
            returned = result

            ->() { returned }
          end

          it 'should return a result with the expected errors' do
            result = instance.call

            expect(result.to_cuprum_result).to be_a Spec::CustomResult
            expect(result.value).to be value
            expect(result.errors).to be nil
            expect(result.success?).to be true
          end
        end

        context 'when the implementation returns a result-like object with ' \
                 'errors' \
        do
          include_context 'when a custom result class is defined'

          let(:expected_errors) { ['errors.messages.unknown'] }
          let(:result)          { Spec::CustomResult.new(nil, expected_errors) }
          let(:implementation) do
            returned = result

            ->() { returned }
          end

          it 'should return a result with the expected errors' do
            result = instance.call

            expect(result.to_cuprum_result).to be_a Spec::CustomResult
            expect(result.value).to be nil
            expect(result.errors).to be == expected_errors
            expect(result.success?).to be false
          end
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
            result = instance.call(10)

            expect(result).to be_a expected_class
            expect(result.value).to be 55
            expect(result.errors).to be nil
          end
        end
      end
    end
  end
end
