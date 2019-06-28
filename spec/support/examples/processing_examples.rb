require 'rspec/sleeping_king_studios/concerns/shared_example_group'

module Spec::Examples
  module ProcessingExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_context 'when a custom result class is defined' do
      options = { :base_class => Struct.new(:value, :errors) }
      example_class 'Spec::CustomResult', options do |klass|
        klass.send(
          :define_method,
          :success?,
          ->() { errors.nil? || errors.empty? }
        ) # end method success?

        klass.send(
          :define_method,
          :to_result,
          ->() { self }
          # ->() { Cuprum::Result.new(value, :errors => errors) }
        ) # end method to_result
      end # class
    end # shared_context

    shared_examples 'should implement the Processing interface' do
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

      describe '#result' do
        it 'should define the reader' do
          expect(instance).
            to have_reader(:result, :allow_private => true).
            with_value(nil)
        end # it
      end # describe
    end # shared_examples

    shared_examples 'should implement the Processing methods' do
      describe '#build_result' do
        include_context 'when a custom result class is defined'

        let(:value)  { 'returned value'.freeze }
        let(:errors) { [] }

        it 'should define the private method' do
          expect(instance).not_to respond_to(:build_result)

          expect(instance).
            to respond_to(:build_result, true).
            with(1).argument.
            and_keywords(:errors)
        end # it

        it 'should return a result' do
          result = instance.send(:build_result, value, :errors => errors)

          expect(result).to be_a Cuprum::Result
          expect(result.value).to be value
          expect(result.errors).to be errors
        end # it

        it 'should return a new object each time it is called' do
          result = instance.send(:build_result, value, :errors => errors)

          expect(instance.send :build_result, value, :errors => errors).
            not_to be result
        end # it

        context 'when a custom result object is returned' do
          let(:custom_result) { Spec::CustomResult.new(value, []) }

          before(:example) do
            allow(instance).to receive(:process).and_return(value)
            allow(instance).
              to receive(:build_result).
              and_return(custom_result)
          end # before

          it 'should return the custom result when called' do
            result = instance.call.to_result

            expect(result).to be custom_result
            expect(result.value).to be value
          end # it
        end # context
      end # describe

      describe '#result' do
        context 'when the #process method is executed' do
          it 'should return the current result' do
            result_during_process = nil

            allow(instance).to receive(:process) do
              result_during_process = instance.send(:result)

              nil
            end # instance

            returned_result = instance.call.to_result

            expect(result_during_process).to be_a Cuprum::Result
            expect(result_during_process).to be returned_result
          end # it
        end # context
      end # describe
    end # shared_examples

    shared_examples 'should execute the command implementation' do
      it 'should raise an error' do
        expect { instance.call }.
          to raise_error Cuprum::Errors::ProcessNotImplementedError
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
          let(:result) { Cuprum::Result.new(value: value) }
          let(:implementation) do
            returned = result

            ->() { returned }
          end # let

          include_examples 'should return a result with the expected value'
        end # context

        context 'when the implementation returns a result with errors' do
          let(:expected_errors) { ['errors.messages.unknown'.freeze] }
          let(:result) do
            Cuprum::Result.new(errors: expected_errors)
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
          include_context 'when a custom result class is defined'

          let(:result) { Spec::CustomResult.new(nil, []) }
          let(:implementation) do
            returned = result

            ->() { returned }
          end # let

          include_examples 'should return an empty result'
        end # context

        context 'when the implementation returns a result-like object with ' \
                 'a value' \
        do
          include_context 'when a custom result class is defined'

          let(:value)  { 'returned value'.freeze }
          let(:result) { Spec::CustomResult.new(value, []) }
          let(:implementation) do
            returned = result

            ->() { returned }
          end # let

          it 'should return a result with the expected errors' do
            result = instance.call

            expect(result.to_result).to be_a Spec::CustomResult
            expect(result.value).to be value
            expect(result.errors).to be_empty
            expect(result.success?).to be true
          end # it
        end # context

        context 'when the implementation returns a result-like object with ' \
                 'errors' \
        do
          include_context 'when a custom result class is defined'

          let(:expected_errors) { ['errors.messages.unknown'.freeze] }
          let(:result)          { Spec::CustomResult.new(nil, expected_errors) }
          let(:implementation) do
            returned = result

            ->() { returned }
          end # let

          it 'should return a result with the expected errors' do
            result = instance.call

            expect(result.to_result).to be_a Spec::CustomResult
            expect(result.value).to be nil
            expect(result.errors).to be == expected_errors
            expect(result.success?).to be false
          end # it
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
