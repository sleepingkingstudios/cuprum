require 'rspec/sleeping_king_studios/concerns/shared_example_group'

module Spec::Examples
  module ProcessingExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_examples 'should implement the Processing methods' do
      describe '#arity' do
        include_examples 'should have reader',
          :arity,
          ->() { instance.method(:process).arity }
      end # describe

      describe '#call' do
        it 'should define the method' do
          expect(instance).
            to respond_to(:call).
            with_unlimited_arguments.
            and_a_block
        end # it
      end # describe
    end # shared_examples

    shared_examples 'should execute the command implementation' do
      it 'should raise an error' do
        expect { instance.call }.
          to raise_error Cuprum::NotImplementedError
      end # it

      context 'when the implementation does not support the given arguments' \
      do
        include_context 'when the implementation is defined'

        let(:implementation) { ->() {} }
        let(:arguments)      { %i[ichi ni san] }

        it 'should raise an error' do
          expect { instance.call(*arguments) }.
            to raise_error ArgumentError,
              'wrong number of arguments (given 3, expected 0)'
        end # it
      end # context

      context 'when the implementation supports the given arguments' do
        include_context 'when the implementation is defined'

        let(:arguments) { %i[ichi ni san] }
        let(:keywords)  { { :yon => 4, :go => 5 } }
        let(:called_arguments) do
          []
        end # let
        let(:implementation) do
          called = called_arguments

          lambda do |*args, &block|
            called.concat(args)

            block&.call
          end # lambda
        end # let

        it 'should forward all arguments to the implementation' do
          yielded = false

          instance.call(*arguments, **keywords, &->() { yielded = true })

          expect(called_arguments).to be == [*arguments, keywords]
          expect(yielded).to be true
        end # it
      end # context

      wrap_context 'when the implementation is defined' do
        shared_examples 'should return an empty result' do
          it 'should return a result' do
            result = instance.call

            expect(result).to be_a result_class
            expect(result.value).to be nil
            expect(result.errors).to be_empty
            expect(result.success?).to be true
            expect(result.failure?).to be false
            expect(result.halted?).to be false
          end # it
        end # shared_examples

        shared_examples 'should return a result with the expected value' do
          it 'should return a result with the expected value' do
            result = instance.call

            expect(result).to be_a result_class
            expect(result.value).to be value
            expect(result.errors).to be_empty
            expect(result.success?).to be true
            expect(result.failure?).to be false
            expect(result.halted?).to be false
          end # it
        end # shared_examples

        shared_examples 'should return a result with the expected errors' do
          it 'should return a result with the expected errors' do
            result = instance.call

            expect(result).to be_a result_class
            expect(result.value).to be nil
            expect(result.errors).to be == expected_errors
            expect(result.success?).to be false
            expect(result.failure?).to be true
            expect(result.halted?).to be false
          end # it
        end # shared_examples

        shared_examples 'should return a failing result' do
          it 'should return a failing result' do
            result = instance.call

            expect(result).to be_a result_class
            expect(result.value).to be nil
            expect(result.errors).to be_empty
            expect(result.success?).to be false
            expect(result.failure?).to be true
            expect(result.halted?).to be false
          end # it
        end # shared_examples

        shared_examples 'should return a halted result' do
          it 'should return a halted result' do
            result = instance.call

            expect(result).to be_a result_class
            expect(result.value).to be nil
            expect(result.errors).to be_empty
            expect(result.success?).to be true
            expect(result.failure?).to be false
            expect(result.halted?).to be true
          end # it
        end # shared_examples

        shared_examples 'should display a warning when returning a result' do
          context 'when a result is returned', :allow_warnings do
            let(:value) { Cuprum::Result.new }

            it 'should display a warning' do
              allow(Cuprum).to receive(:warn)

              instance.call

              expect(Cuprum).to have_received(:warn).with(an_instance_of String)
            end # it
          end # context
        end # shared_examples

        let(:custom_class) do
          Class.new(Struct.new :value, :errors) do
            def success?
              errors.nil? || errors.empty?
            end # method success

            def to_result
              Cuprum::Result.new(value, :errors => errors)
            end # method to_result
          end # class
        end # let
        let(:value) { nil }

        include_examples 'should return an empty result'

        context 'when the implementation returns a value' do
          let(:value) { 'returned value'.freeze }
          let(:implementation) do
            returned = value

            ->() { returned }
          end # let

          include_examples 'should return a result with the expected value'
        end # context

        context 'when the implementation sets the errors' do
          let(:expected_errors) { ['errors.messages.unknown'.freeze] }
          let(:implementation) do
            returned = value
            errors   = expected_errors

            lambda do
              result.errors.concat(errors)

              returned
            end # lambda
          end # let

          include_examples 'should return a result with the expected errors'

          include_examples 'should display a warning when returning a result'
        end # context

        context 'when the implementation sets the status' do
          let(:implementation) do
            returned = value

            lambda do
              result.failure!

              returned
            end # lambda
          end # let

          include_examples 'should return a failing result'

          include_examples 'should display a warning when returning a result'
        end # context

        context 'when the implementation halts the result' do
          let(:implementation) do
            returned = value

            lambda do
              result.halt!

              returned
            end # lambda
          end # let

          include_examples 'should return a halted result'

          include_examples 'should display a warning when returning a result'
        end # context

        context 'when the implementation returns the current result' do
          let(:implementation) do
            ->() { result }
          end # let

          include_examples 'should return an empty result'
        end # context

        context 'when the implementation returns an empty result' do
          let(:result) { Cuprum::Result.new }
          let(:implementation) do
            returned = result

            ->() { returned }
          end # let

          include_examples 'should return an empty result'
        end # context

        context 'when the implementation returns a result with a value' do
          let(:value)  { 'returned value'.freeze }
          let(:result) { Cuprum::Result.new(value) }
          let(:implementation) do
            returned = result

            ->() { returned }
          end # let

          include_examples 'should return a result with the expected value'
        end # context

        context 'when the implementation returns a result with errors' do
          let(:expected_errors) { ['errors.messages.unknown'.freeze] }
          let(:result) do
            Cuprum::Result.new(nil, :errors => expected_errors)
          end # let
          let(:implementation) do
            returned = result

            ->() { returned }
          end # let

          include_examples 'should return a result with the expected errors'
        end # context

        context 'when the implementation returns a failing result' do
          let(:result) { Cuprum::Result.new.failure! }
          let(:implementation) do
            returned = result

            ->() { returned }
          end # let

          include_examples 'should return a failing result'
        end # context

        context 'when the implementation returns a halted result' do
          let(:result) { Cuprum::Result.new.halt! }
          let(:implementation) do
            returned = result

            ->() { returned }
          end # let

          include_examples 'should return a halted result'
        end # context

        context 'when the implementation returns a result-like object' do
          let(:result) { custom_class.new(nil, []) }
          let(:implementation) do
            returned = result

            ->() { returned }
          end # let

          include_examples 'should return an empty result'
        end # context

        context 'when the implementation returns a result-like object with ' \
                 'a value' \
        do
          let(:value)  { 'returned value'.freeze }
          let(:result) { custom_class.new(value, []) }
          let(:implementation) do
            returned = result

            ->() { returned }
          end # let

          include_examples 'should return a result with the expected value'
        end # context

        context 'when the implementation returns a result-like object with ' \
                 'errors' \
        do
          let(:expected_errors) { ['errors.messages.unknown'.freeze] }
          let(:result)          { custom_class.new(nil, expected_errors) }
          let(:implementation) do
            returned = result

            ->() { returned }
          end # let

          include_examples 'should return a result with the expected errors'
        end # context

        context 'when the implementation calls itself' do
          let(:implementation) do
            lambda do |int|
              return 0 if int < 1

              return 1 if int == 1

              call(int - 1).value + call(int - 2).value
            end # lambda
          end # let

          it 'should return a result', :aggregate_failures do
            result = instance.call(10)

            expect(result).to be_a result_class
            expect(result.value).to be 55
            expect(result.errors).to be_empty
          end # it
        end # context
      end # wrap_context
    end # shared_examples
  end # module
end # module
