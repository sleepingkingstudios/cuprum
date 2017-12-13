require 'rspec/sleeping_king_studios/concerns/shared_example_group'

module Spec::Examples
  module CommandExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_context 'when the command is initialized with a block' do
      subject(:instance) { described_class.new(&implementation) }
    end # shared_context

    shared_context 'when the #process method is defined' do
      let(:described_class) do
        Class.new(super()).tap do |klass|
          klass.send :define_method, :process, &implementation
        end # class
      end # let
    end # shared_context

    shared_examples 'should implement the Command methods' do
      describe '#arity' do
        include_examples 'should have reader',
          :arity,
          ->() { instance.method(:process).arity }
      end # describe

      describe '#call' do
        it { expect(instance).to respond_to(:call) }
      end # describe
    end # shared_examples

    shared_examples 'should implement the Command methods for any ' \
                    'implementation' do
      shared_context 'when the command is executing the implementation' do
        def call_with_implementation &block
          example  = self
          instance =
            described_class.new { example.instance_exec(self, &block) }

          instance.call
        end # method implement_with
      end # shared_context

      describe '#build_errors' do
        it 'should define the private method' do
          expect(instance).not_to respond_to(:build_errors)

          expect(instance).to respond_to(:build_errors, true).with(0).arguments
        end # it

        it 'should return an empty array' do
          errors = instance.send(:build_errors)

          expect(errors).to be_a Array
          expect(errors).to be_empty
        end # it

        it 'should return a new object each time it is called' do
          errors = instance.send(:build_errors)

          expect(instance.send :build_errors).not_to be errors
        end # it
      end # describe

      describe '#call' do
        shared_context 'when the implementation returns an operation' do
          let(:value_or_result) do
            returned = value

            Cuprum::Operation.new { returned }.call
          end # let
        end # shared_context

        shared_context 'when the implementation returns a failing operation' do
          let(:value_or_result) do
            returned = value

            Cuprum::Operation.new do
              result.failure!

              returned
            end. # operation
              call
          end # let
        end # shared_context

        shared_context 'when the implementation returns an operation with ' \
                       'errors' do
          let(:implementation_errors) do
            ['errors.messages.custom']
          end # let
          let(:value_or_result) do
            messages = implementation_errors
            returned = value

            Cuprum::Operation.new do
              send(:errors).concat(messages)

              returned
            end. # operation
              call
          end # let
        end # shared_context

        shared_context 'when the implementation returns a halted operation' do
          let(:value_or_result) do
            returned = value

            Cuprum::Operation.new do
              result.halt!

              returned
            end. # operation
              call
          end # let
        end # shared_context

        shared_context 'when the implementation returns a result' do
          let(:value_or_result) { Cuprum::Result.new(value) }
        end # shared_context

        shared_context 'when the implementation returns a failing result' do
          let(:value_or_result) { Cuprum::Result.new(value).tap(&:failure!) }
        end # shared_context

        shared_context 'when the implementation returns a result with errors' do
          let(:implementation_errors) do
            ['errors.messages.custom']
          end # let
          let(:value_or_result) do
            Cuprum::Result.new(value, :errors => implementation_errors)
          end # let
        end # shared_context

        shared_context 'when the implementation returns a halted result' do
          let(:value_or_result) { Cuprum::Result.new(value).halt! }
        end # shared_context

        shared_context 'when the implementation returns the current result' do
          let(:implementation) do
            returned_value = value

            ->() { result.tap { |obj| obj.value = returned_value } }
          end # let
        end # shared_context

        shared_examples 'should forward all arguments' do
          context 'when the implementation does not support the given ' \
                  'arguments' do
            let(:arguments) { %i[ichi ni san] }

            it 'should raise an error' do
              expect { instance.call(*arguments) }.
                to raise_error ArgumentError,
                  'wrong number of arguments (given 3, expected 0)'
            end # it
          end # context

          context 'when the implementation supports the given arguments' do
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
        end # shared_examples

        shared_examples 'should return a result' do
          shared_examples 'should display a warning' do
            it 'should display a warning', :allow_warnings do
              allow(Cuprum).to receive(:warn)

              instance.call

              expect(Cuprum).to have_received(:warn).with(warning_message)
            end # it
          end # shared_examples

          context 'when the operation does not generate any errors' do
            let(:value)           { 'returned value'.freeze }
            let(:value_or_result) { value }
            let(:implementation) do
              returned = value_or_result

              ->() { returned }
            end # let

            it 'should return a result', :aggregate_failures do
              result = instance.call

              expect(result).to be_a result_class
              expect(result.value).to be value
              expect(result.errors).to be_empty
              expect(result.success?).to be true
              expect(result.failure?).to be false
              expect(result.halted?).to be false
            end # it

            wrap_context 'when the implementation returns an operation' do
              it 'should return a result', :aggregate_failures do
                result = instance.call

                expect(result).to be_a result_class
                expect(result.value).to be value
                expect(result.errors).to be_empty
                expect(result.success?).to be true
                expect(result.failure?).to be false
                expect(result.halted?).to be false
              end # it
            end # wrap_context

            wrap_context 'when the implementation returns a failing operation' \
            do
              it 'should return a result', :aggregate_failures do
                result = instance.call

                expect(result).to be_a result_class
                expect(result.value).to be value
                expect(result.errors).to be_empty
                expect(result.success?).to be false
                expect(result.failure?).to be true
                expect(result.halted?).to be false
              end # it
            end # wrap_context

            wrap_context 'when the implementation returns an operation with ' \
                         'errors' do
              it 'should return a result', :aggregate_failures do
                result = instance.call

                expect(result).to be_a result_class
                expect(result.value).to be value
                expect(result.errors).to be == implementation_errors
                expect(result.success?).to be false
                expect(result.failure?).to be true
                expect(result.halted?).to be false
              end # it
            end # wrap_context

            wrap_context 'when the implementation returns a halted operation' do
              it 'should return a result', :aggregate_failures do
                result = instance.call

                expect(result).to be_a result_class
                expect(result.value).to be value
                expect(result.errors).to be_empty
                expect(result.success?).to be true
                expect(result.failure?).to be false
                expect(result.halted?).to be true
              end # it
            end # wrap_context

            wrap_context 'when the implementation returns a result' do
              it 'should return a result', :aggregate_failures do
                result = instance.call

                expect(result).to be_a result_class
                expect(result.value).to be value
                expect(result.errors).to be_empty
                expect(result.success?).to be true
                expect(result.failure?).to be false
                expect(result.halted?).to be false
              end # it
            end # wrap_context

            wrap_context 'when the implementation returns a failing result' do
              it 'should return a result', :aggregate_failures do
                result = instance.call

                expect(result).to be_a result_class
                expect(result.value).to be value
                expect(result.errors).to be_empty
                expect(result.success?).to be false
                expect(result.failure?).to be true
                expect(result.halted?).to be false
              end # it
            end # wrap_context

            wrap_context 'when the implementation returns a result with errors'\
            do
              it 'should return a result', :aggregate_failures do
                result = instance.call

                expect(result).to be_a result_class
                expect(result.value).to be value
                expect(result.errors).to be == implementation_errors
                expect(result.success?).to be false
                expect(result.failure?).to be true
                expect(result.halted?).to be false
              end # it
            end # wrap_context

            wrap_context 'when the implementation returns a halted result' do
              it 'should return a result', :aggregate_failures do
                result = instance.call

                expect(result).to be_a result_class
                expect(result.value).to be value
                expect(result.errors).to be_empty
                expect(result.success?).to be true
                expect(result.failure?).to be false
                expect(result.halted?).to be true
              end # it
            end # wrap_context

            wrap_context 'when the implementation returns the current result' do
              it 'should return a result', :aggregate_failures do
                result = instance.call

                expect(result).to be_a result_class
                expect(result.value).to be value
                expect(result.errors).to be_empty
                expect(result.success?).to be true
                expect(result.failure?).to be false
                expect(result.halted?).to be false
              end # it
            end # wrap_context
          end # context

          context 'when the operation generates errors' do
            let(:value)           { 'returned value'.freeze }
            let(:value_or_result) { value }
            let(:expected_errors) do
              ['errors.messages.unknown']
            end # let
            let(:implementation) do
              messages = expected_errors
              returned = value_or_result

              lambda do
                messages.each do |message|
                  result.errors << message
                end # each

                returned
              end # lambda
            end # let
            let(:warning_message) do
              '#process returned a result, but there were already errors ' \
              "#{expected_errors.inspect}"
            end # let

            it 'should return a result', :aggregate_failures do
              result = instance.call

              expect(result).to be_a result_class
              expect(result.value).to be value

              expected_errors.each do |message|
                expect(result.errors).to include message
              end # each

              expect(result.success?).to be false
              expect(result.failure?).to be true
              expect(result.halted?).to be false
            end # it

            wrap_context 'when the implementation returns an operation' do
              it 'should return a result',
                :aggregate_failures,
                :suppress_warnings \
              do
                result = instance.call

                expect(result).to be_a result_class
                expect(result.value).to be value
                expect(result.errors).to be_empty
                expect(result.success?).to be true
                expect(result.failure?).to be false
                expect(result.halted?).to be false
              end # it

              include_examples 'should display a warning'
            end # wrap_context

            wrap_context 'when the implementation returns a failing operation' \
            do
              it 'should return a result',
                :aggregate_failures,
                :suppress_warnings \
              do
                result = instance.call

                expect(result).to be_a result_class
                expect(result.value).to be value
                expect(result.errors).to be_empty
                expect(result.success?).to be false
                expect(result.failure?).to be true
                expect(result.halted?).to be false
              end # it

              include_examples 'should display a warning'
            end # wrap_context

            wrap_context 'when the implementation returns an operation with ' \
            'errors' do
              let(:implementation_errors) { ['errors.messages.custom'] }

              it 'should return a result', # rubocop:disable RSpec/ExampleLength
                :aggregate_failures,
                :suppress_warnings \
              do
                result = instance.call

                expect(result).to be_a result_class
                expect(result.value).to be value

                implementation_errors.each do |message|
                  expect(result.errors).to include message
                end # each

                expect(result.success?).to be false
                expect(result.failure?).to be true
                expect(result.halted?).to be false
              end # it

              include_examples 'should display a warning'
            end # wrap_context

            wrap_context 'when the implementation returns a halted operation' do
              it 'should return a result',
                :aggregate_failures,
                :suppress_warnings \
              do
                result = instance.call

                expect(result).to be_a result_class
                expect(result.value).to be value
                expect(result.errors).to be_empty
                expect(result.success?).to be true
                expect(result.failure?).to be false
                expect(result.halted?).to be true
              end # it

              include_examples 'should display a warning'
            end # wrap_context

            wrap_context 'when the implementation returns a result' do
              it 'should return a result',
                :aggregate_failures,
                :suppress_warnings \
              do
                result = instance.call

                expect(result).to be_a result_class
                expect(result.value).to be value
                expect(result.errors).to be_empty
                expect(result.success?).to be true
                expect(result.failure?).to be false
                expect(result.halted?).to be false
              end # it

              include_examples 'should display a warning'
            end # wrap_context

            wrap_context 'when the implementation returns a failing result' do
              it 'should return a result',
                :aggregate_failures,
                :suppress_warnings \
              do
                result = instance.call

                expect(result).to be_a result_class
                expect(result.value).to be value
                expect(result.errors).to be_empty
                expect(result.success?).to be false
                expect(result.failure?).to be true
                expect(result.halted?).to be false
              end # it

              include_examples 'should display a warning'
            end # wrap_context

            wrap_context 'when the implementation returns a result with errors'\
            do
              let(:implementation_errors) { ['errors.messages.custom'] }

              it 'should return a result', # rubocop:disable RSpec/ExampleLength
                :aggregate_failures,
                :suppress_warnings \
              do
                result = instance.call

                expect(result).to be_a result_class
                expect(result.value).to be value

                implementation_errors.each do |message|
                  expect(result.errors).to include message
                end # each

                expect(result.success?).to be false
                expect(result.failure?).to be true
                expect(result.halted?).to be false
              end # it

              include_examples 'should display a warning'
            end # wrap_context

            wrap_context 'when the implementation returns a halted result' do
              it 'should return a result',
                :aggregate_failures,
                :suppress_warnings \
              do
                result = instance.call

                expect(result).to be_a result_class
                expect(result.value).to be value
                expect(result.errors).to be_empty
                expect(result.success?).to be true
                expect(result.failure?).to be false
                expect(result.halted?).to be true
              end # it

              include_examples 'should display a warning'
            end # wrap_context
          end # context

          context 'when the operation sets the status' do
            let(:value)           { 'returned value'.freeze }
            let(:value_or_result) { value }
            let(:expected_errors) { [] }
            let(:implementation) do
              returned = value_or_result

              lambda do
                result.failure!

                returned
              end # lambda
            end # let
            let(:warning_message) do
              '#process returned a result, but the status was set to :failure'
            end # let

            it 'should return a result', :aggregate_failures do
              result = instance.call

              expect(result).to be_a result_class
              expect(result.value).to be value
              expect(result.errors).to be_empty
              expect(result.success?).to be false
              expect(result.failure?).to be true
              expect(result.halted?).to be false
            end # it

            wrap_context 'when the implementation returns an operation' do
              it 'should return a result',
                :aggregate_failures,
                :suppress_warnings \
              do
                result = instance.call

                expect(result).to be_a result_class
                expect(result.value).to be value
                expect(result.errors).to be_empty
                expect(result.success?).to be true
                expect(result.failure?).to be false
                expect(result.halted?).to be false
              end # it

              include_examples 'should display a warning'
            end # wrap_context

            wrap_context 'when the implementation returns a failing operation' \
            do
              it 'should return a result',
                :aggregate_failures,
                :suppress_warnings \
              do
                result = instance.call

                expect(result).to be_a result_class
                expect(result.value).to be value
                expect(result.errors).to be_empty
                expect(result.success?).to be false
                expect(result.failure?).to be true
                expect(result.halted?).to be false
              end # it

              include_examples 'should display a warning'
            end # wrap_context

            wrap_context 'when the implementation returns an operation with ' \
            'errors' do
              let(:implementation_errors) { ['errors.messages.custom'] }

              it 'should return a result', # rubocop:disable RSpec/ExampleLength
                :aggregate_failures,
                :suppress_warnings \
              do
                result = instance.call

                expect(result).to be_a result_class
                expect(result.value).to be value

                implementation_errors.each do |message|
                  expect(result.errors).to include message
                end # each

                expect(result.success?).to be false
                expect(result.failure?).to be true
                expect(result.halted?).to be false
              end # it

              include_examples 'should display a warning'
            end # wrap_context

            wrap_context 'when the implementation returns a halted operation' do
              it 'should return a result',
                :aggregate_failures,
                :suppress_warnings \
              do
                result = instance.call

                expect(result).to be_a result_class
                expect(result.value).to be value
                expect(result.errors).to be_empty
                expect(result.success?).to be true
                expect(result.failure?).to be false
                expect(result.halted?).to be true
              end # it

              include_examples 'should display a warning'
            end # wrap_context

            wrap_context 'when the implementation returns a result' do
              it 'should return a result',
                :aggregate_failures,
                :suppress_warnings \
              do
                result = instance.call

                expect(result).to be_a result_class
                expect(result.value).to be value
                expect(result.errors).to be_empty
                expect(result.success?).to be true
                expect(result.failure?).to be false
                expect(result.halted?).to be false
              end # it

              include_examples 'should display a warning'
            end # wrap_context

            wrap_context 'when the implementation returns a failing result' do
              it 'should return a result',
                :aggregate_failures,
                :suppress_warnings \
              do
                result = instance.call

                expect(result).to be_a result_class
                expect(result.value).to be value
                expect(result.errors).to be_empty
                expect(result.success?).to be false
                expect(result.failure?).to be true
                expect(result.halted?).to be false
              end # it

              include_examples 'should display a warning'
            end # wrap_context

            wrap_context 'when the implementation returns a result with errors'\
            do
              let(:implementation_errors) { ['errors.messages.custom'] }

              it 'should return a result', # rubocop:disable RSpec/ExampleLength
                :aggregate_failures,
                :suppress_warnings \
              do
                result = instance.call

                expect(result).to be_a result_class
                expect(result.value).to be value

                implementation_errors.each do |message|
                  expect(result.errors).to include message
                end # each

                expect(result.success?).to be false
                expect(result.failure?).to be true
                expect(result.halted?).to be false
              end # it

              include_examples 'should display a warning'
            end # wrap_context

            wrap_context 'when the implementation returns a halted result' do
              it 'should return a result',
                :aggregate_failures,
                :suppress_warnings \
              do
                result = instance.call

                expect(result).to be_a result_class
                expect(result.value).to be value
                expect(result.errors).to be_empty
                expect(result.success?).to be true
                expect(result.failure?).to be false
                expect(result.halted?).to be true
              end # it

              include_examples 'should display a warning'
            end # wrap_context
          end # context

          context 'when the operation is halted' do
            let(:value)           { 'returned value'.freeze }
            let(:value_or_result) { value }
            let(:implementation) do
              returned = value_or_result

              lambda do
                result.halt!

                returned
              end # lambda
            end # let
            let(:warning_message) do
              '#process returned a result, but the function was halted'
            end # let

            it 'should return a result', :aggregate_failures do
              result = instance.call

              expect(result).to be_a result_class
              expect(result.value).to be value
              expect(result.errors).to be_empty
              expect(result.success?).to be true
              expect(result.failure?).to be false
              expect(result.halted?).to be true
            end # it

            wrap_context 'when the implementation returns an operation' do
              it 'should return a result',
                :aggregate_failures,
                :suppress_warnings \
              do
                result = instance.call

                expect(result).to be_a result_class
                expect(result.value).to be value
                expect(result.errors).to be_empty
                expect(result.success?).to be true
                expect(result.failure?).to be false
                expect(result.halted?).to be false
              end # it

              include_examples 'should display a warning'
            end # wrap_context

            wrap_context 'when the implementation returns a failing operation' \
            do
              it 'should return a result',
                :aggregate_failures,
                :suppress_warnings \
              do
                result = instance.call

                expect(result).to be_a result_class
                expect(result.value).to be value
                expect(result.errors).to be_empty
                expect(result.success?).to be false
                expect(result.failure?).to be true
                expect(result.halted?).to be false
              end # it

              include_examples 'should display a warning'
            end # wrap_context

            wrap_context 'when the implementation returns an operation with ' \
            'errors' do
              let(:implementation_errors) { ['errors.messages.custom'] }

              it 'should return a result', # rubocop:disable RSpec/ExampleLength
                :aggregate_failures,
                :suppress_warnings \
              do
                result = instance.call

                expect(result).to be_a result_class
                expect(result.value).to be value

                implementation_errors.each do |message|
                  expect(result.errors).to include message
                end # each

                expect(result.success?).to be false
                expect(result.failure?).to be true
                expect(result.halted?).to be false
              end # it

              include_examples 'should display a warning'
            end # wrap_context

            wrap_context 'when the implementation returns a halted operation' do
              it 'should return a result',
                :aggregate_failures,
                :suppress_warnings \
              do
                result = instance.call

                expect(result).to be_a result_class
                expect(result.value).to be value
                expect(result.errors).to be_empty
                expect(result.success?).to be true
                expect(result.failure?).to be false
                expect(result.halted?).to be true
              end # it

              include_examples 'should display a warning'
            end # wrap_context

            wrap_context 'when the implementation returns a result' do
              it 'should return a result',
                :aggregate_failures,
                :suppress_warnings \
              do
                result = instance.call

                expect(result).to be_a result_class
                expect(result.value).to be value
                expect(result.errors).to be_empty
                expect(result.success?).to be true
                expect(result.failure?).to be false
                expect(result.halted?).to be false
              end # it

              include_examples 'should display a warning'
            end # wrap_context

            wrap_context 'when the implementation returns a failing result' do
              it 'should return a result',
                :aggregate_failures,
                :suppress_warnings \
              do
                result = instance.call

                expect(result).to be_a result_class
                expect(result.value).to be value
                expect(result.errors).to be_empty
                expect(result.success?).to be false
                expect(result.failure?).to be true
                expect(result.halted?).to be false
              end # it

              include_examples 'should display a warning'
            end # wrap_context

            wrap_context 'when the implementation returns a result with errors'\
            do
              let(:implementation_errors) { ['errors.messages.custom'] }

              it 'should return a result', # rubocop:disable RSpec/ExampleLength
                :aggregate_failures,
                :suppress_warnings \
              do
                result = instance.call

                expect(result).to be_a result_class
                expect(result.value).to be value

                implementation_errors.each do |message|
                  expect(result.errors).to include message
                end # each

                expect(result.success?).to be false
                expect(result.failure?).to be true
                expect(result.halted?).to be false
              end # it

              include_examples 'should display a warning'
            end # wrap_context

            wrap_context 'when the implementation returns a halted result' do
              it 'should return a result',
                :aggregate_failures,
                :suppress_warnings \
              do
                result = instance.call

                expect(result).to be_a result_class
                expect(result.value).to be value
                expect(result.errors).to be_empty
                expect(result.success?).to be true
                expect(result.failure?).to be false
                expect(result.halted?).to be true
              end # it

              include_examples 'should display a warning'
            end # wrap_context
          end # context
        end # shared_examples

        shared_examples 'should support recursive calls' do
          describe 'with an implementation that calls itself' do
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
          end # describe
        end # shared_examples

        it 'should define the method' do
          expect(instance).
            to respond_to(:call).
            with_unlimited_arguments.
            and_a_block
        end # it

        it 'should raise an error' do
          expect { instance.call }.
            to raise_error Cuprum::NotImplementedError,
              'no implementation defined for command'
        end # it

        wrap_context 'when the command is initialized with a block' do
          it 'should not raise an error' do
            expect { instance.call }.not_to raise_error
          end # it

          include_examples 'should forward all arguments'

          include_examples 'should return a result'

          include_examples 'should support recursive calls'
        end # wrap_context

        wrap_context 'when the #process method is defined' do
          it 'should not raise an error' do
            expect { instance.call }.not_to raise_error
          end # it

          include_examples 'should forward all arguments'

          include_examples 'should return a result'

          include_examples 'should support recursive calls'
        end # wrap_context
      end # describe

      describe '#halt!' do
        it 'should define the private method' do
          expect(instance).not_to respond_to(:halt!)

          expect(instance).to respond_to(:halt!, true).with(0).arguments
        end # it

        it { expect(instance.send(:halt!)).to be_nil }

        wrap_context 'when the command is executing the implementation' do
          it { expect(instance.send(:halt!)).to be_nil }

          it 'should halt the result' do
            result =
              call_with_implementation do |instance|
                instance.send(:halt!)

                nil
              end # call_with_implementation

            expect(result.halted?).to be true
          end # it
        end # method wrap_context
      end # describe

      describe '#result' do
        it 'should define the reader' do
          expect(instance).
            to have_reader(:result, :allow_private => true).
            with_value(nil)
        end # it

        wrap_context 'when the command is executing the implementation' do
          it 'should return the current result' do
            inner_result = nil
            outer_result =
              call_with_implementation do |instance|
                inner_result = instance.send(:result)
              end # call_with_implementation

            expect(inner_result).to be_a Cuprum::Result
            expect(inner_result).to be == outer_result.to_result
          end # it
        end # wrap_context
      end # describe

      describe '#success!' do
        it 'should define the private method' do
          expect(instance).not_to respond_to(:success!)

          expect(instance).to respond_to(:success!, true).with(0).arguments
        end # it

        it { expect(instance.send(:success!)).to be_nil }

        wrap_context 'when the command is executing the implementation' do
          it { expect(instance.send(:success!)).to be_nil }

          it 'should mark the result as successful' do
            result =
              call_with_implementation do |instance|
                instance.send(:result).errors << 'errors.messages.unknown'

                instance.send(:success!)

                nil
              end # call_with_implementation

            expect(result.success?).to be true
          end # it
        end # method wrap_context
      end # describe
    end # shared_examples
  end # module
end # module
