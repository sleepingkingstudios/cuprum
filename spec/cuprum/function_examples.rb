require 'rspec/sleeping_king_studios/concerns/shared_example_group'

module Spec::Examples
  module FunctionExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_context 'when the function is initialized with a block' do
      subject(:instance) { described_class.new(&implementation) }
    end # shared_context

    shared_context 'when the #process method is defined' do
      let(:described_class) do
        Class.new(super()).tap do |klass|
          klass.send :define_method, :process, &implementation
        end # class
      end # let
    end # shared_context

    shared_examples 'should implement the Function methods' do
      shared_context 'when the function is failing' do
        let(:expected_errors) do
          ['errors.messages.unknown']
        end # let
        let(:last_success) { false }
        let(:implementation) do
          called   = called_functions
          messages = expected_errors
          returned = value

          lambda do
            called << 'first function'.freeze

            messages.each do |message|
              errors << message
            end # each

            [returned]
          end # lambda
        end # let
      end # shared_context

      shared_context 'when the function is halted' do
        let(:implementation) do
          called   = called_functions
          returned = value

          lambda do
            called << 'first function'.freeze

            halt!

            [returned]
          end # lambda
        end # let
      end # shared_context

      shared_context 'when a previous function is failing' do
        let(:expected_errors) do
          ['errors.messages.unknown']
        end # let
        let(:expected_called) { super() << 'rescue function'.freeze }
        let(:expected_value)  { super() << 'rescue value'.freeze }
        let(:last_success) { true }
        let(:implementation) do
          called   = called_functions
          messages = expected_errors
          returned = value

          lambda do
            called << 'first function'.freeze

            messages.each do |message|
              errors << message
            end # each

            [returned]
          end # lambda
        end # let
        let(:instance) do
          called = called_functions

          super().chain do |result|
            called << 'rescue function'.freeze

            Cuprum::Result.new(result.value + ['rescue value'.freeze])
          end # chain
        end # let
      end # shared_context

      shared_context 'when the function has one chained function' do
        let(:expected_called) do
          super() << 'second function'.freeze
        end # let
        let(:expected_value) do
          super() << 'second value'.freeze
        end # let
        let(:instance) do
          called = called_functions

          super().chain do |result|
            called << 'second function'.freeze

            Cuprum::Result.new(result.value + ['second value'.freeze])
          end # result
        end # let
      end # shared_context

      shared_context 'when the function has many chained functions' do
        let(:expected_called) do
          super() <<
            'second function'.freeze <<
            'third function'.freeze <<
            'fourth function'.freeze
        end # let
        let(:expected_value) do
          super() <<
            'second value'.freeze <<
            'third value'.freeze <<
            'fourth value'.freeze
        end # let
        let(:instance) do
          called = called_functions

          super().
            chain do |result|
              called << 'second function'.freeze

              Cuprum::Result.new(result.value + ['second value'.freeze])
            end. # result
            chain do |result|
              called << 'third function'.freeze

              Cuprum::Result.new(result.value + ['third value'.freeze])
            end. # result
            chain do |result|
              called << 'fourth function'.freeze

              Cuprum::Result.new(result.value + ['fourth value'.freeze])
            end # result
        end # let
      end # shared_context

      shared_context 'when the function is executing the implementation' do
        def call_with_implementation &block
          example  = self
          instance =
            described_class.new { example.instance_exec(self, &block) }

          instance.call
        end # method implement_with
      end # shared_context

      shared_examples 'should copy the function' do
        it 'should copy the function' do
          copy = chain_function(other_function)

          expect(copy).to be_a described_class
          expect(copy).not_to be instance
        end # it
      end # shared_examples

      shared_examples 'should call each chained function' do
        it 'should call each chained function' do
          chain_function(other_function).call

          expect(called_functions).to be == expected_called
        end # it
      end # shared_examples

      shared_examples 'should chain the function' do
        describe 'should chain the function' do
          let(:other_value)     { 'last value'.freeze }
          let(:expected_called) { super() << 'last function'.freeze }

          describe 'with a block that returns an operation' do
            let(:expected_value) { super() << other_value }
            let(:other_function) do
              called   = called_functions
              returned = other_value

              lambda do |result|
                called << 'last function'.freeze

                Cuprum::Operation.new { result.value + [returned] }.call
              end # lambda
            end # let

            include_examples 'should copy the function'

            include_examples 'should call each chained function'

            it 'should return the function result' do
              result = chain_function(other_function).call

              expect(result).to be_a result_class
              expect(result.success?).to be true
              expect(result.value).to be == expected_value
            end # it
          end # describe

          describe 'with a block that returns a result' do
            let(:expected_value) { super() << other_value }
            let(:other_function) do
              called   = called_functions
              returned = other_value

              lambda do |result|
                called << 'last function'.freeze

                Cuprum::Result.new(result.value + [returned])
              end # lambda
            end # let

            include_examples 'should copy the function'

            include_examples 'should call each chained function'

            it 'should return the function result' do
              result = chain_function(other_function).call

              expect(result).to be_a result_class
              expect(result.success?).to be true
              expect(result.value).to be == expected_value
            end # it
          end # describe

          describe 'with a block that returns a value' do
            let(:other_function) do
              called   = called_functions
              returned = other_value

              lambda do |result|
                called << 'last function'.freeze

                result.value + [returned]
              end # lambda
            end # let

            include_examples 'should copy the function'

            include_examples 'should call each chained function'

            it 'should return the previous result' do
              result = chain_function(other_function).call

              expect(result).to be_a result_class
              expect(result.success?).to be last_success
              expect(result.value).to be == expected_value
            end # it
          end # describe

          describe 'with a function' do
            let(:expected_value) { super() << other_value }
            let(:other_function) do
              called   = called_functions
              returned = other_value

              Cuprum::Function.new do |result|
                called << 'last function'.freeze

                result.value << returned
              end # function
            end # let

            include_examples 'should copy the function'

            include_examples 'should call each chained function'

            it 'should return the function result' do
              result = chain_function(other_function).call

              expect(result).to be_a result_class
              expect(result.success?).to be true
              expect(result.value).to be == expected_value
            end # it
          end # describe
        end # describe
      end # shared_examples

      shared_examples 'should chain but not call the function' do
        describe 'should chain but not call the function' do
          let(:other_value) { 'last value'.freeze }

          describe 'with a block that returns an operation' do
            let(:other_function) do
              called   = called_functions
              returned = other_value

              lambda do |result|
                # :nocov:
                called << 'last function'.freeze

                Cuprum::Operation.new { result.value + [returned] }.call
                # :nocov:
              end # lambda
            end # let

            include_examples 'should copy the function'

            include_examples 'should call each chained function'

            it 'should return the previous result' do
              result = chain_function(other_function).call

              expect(result).to be_a result_class
              expect(result.success?).to be last_success
              expect(result.value).to be == expected_value
            end # it
          end # describe

          describe 'with a block that returns a result' do
            let(:other_function) do
              called   = called_functions
              returned = other_value

              lambda do |result|
                # :nocov:
                called << 'last function'.freeze

                Cuprum::Result.new(result.value + [returned])
                # :nocov:
              end # lambda
            end # let

            include_examples 'should copy the function'

            include_examples 'should call each chained function'

            it 'should return the previous result' do
              result = chain_function(other_function).call

              expect(result).to be_a result_class
              expect(result.success?).to be last_success
              expect(result.value).to be == expected_value
            end # it
          end # describe

          describe 'with a block that returns a value' do
            let(:other_function) do
              called   = called_functions
              returned = other_value

              lambda do |result|
                # :nocov:
                called << 'last function'.freeze

                result.value + [returned]
                # :nocov:
              end # lambda
            end # let

            include_examples 'should copy the function'

            include_examples 'should call each chained function'

            it 'should return the previous result' do
              result = chain_function(other_function).call

              expect(result).to be_a result_class
              expect(result.success?).to be last_success
              expect(result.value).to be == expected_value
            end # it
          end # describe

          describe 'with a function' do
            let(:other_function) do
              called   = called_functions
              returned = other_value

              Cuprum::Function.new do |result|
                # :nocov:
                called << 'last function'.freeze

                result.value << returned
                # :nocov:
              end # function
            end # let

            include_examples 'should copy the function'

            include_examples 'should call each chained function'

            it 'should return the previous result' do
              result = chain_function(other_function).call

              expect(result).to be_a result_class
              expect(result.success?).to be last_success
              expect(result.value).to be == expected_value
            end # it
          end # describe
        end # describe
      end # shared_examples

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
          context 'when the operation does not generate any errors' do
            let(:value) { 'returned value'.freeze }
            let(:implementation) do
              returned = value

              ->() { returned }
            end # let

            it 'should return a result', :aggregate_failures do
              result = instance.call

              expect(result).to be_a result_class
              expect(result.value).to be value
              expect(result.errors).to be_empty
            end # it

            context 'when the implementation returns an operation' do
              let(:implementation) do
                returned = value

                ->() { Cuprum::Operation.new { returned }.call }
              end # let

              it 'should return a result', :aggregate_failures do
                result = instance.call

                expect(result).to be_a result_class
                expect(result.value).to be value
                expect(result.errors).to be_empty
              end # it
            end # context

            context 'when the implementation returns an operation with errors' \
            do
              let(:implementation_errors) do
                ['errors.messages.custom']
              end # let
              let(:implementation) do
                messages = implementation_errors
                returned = value

                lambda do
                  Cuprum::Operation.new do
                    send(:errors).concat(messages)

                    returned
                  end. # operation
                    call
                end # lambda
              end # let

              it 'should return a result', :aggregate_failures do
                result = instance.call

                expect(result).to be_a result_class
                expect(result.value).to be value
                expect(result.errors).to be == implementation_errors
                expect(result.failure?).to be true
              end # it
            end # context

            context 'when the implementation returns a result' do
              let(:implementation) do
                returned = value

                ->() { Cuprum::Result.new(returned) }
              end # let

              it 'should return a result', :aggregate_failures do
                result = instance.call

                expect(result).to be_a result_class
                expect(result.value).to be value
                expect(result.errors).to be_empty
              end # it
            end # context

            context 'when the implementation returns a result with errors' do
              let(:implementation_errors) do
                ['errors.messages.custom']
              end # let
              let(:implementation) do
                errors   = implementation_errors
                returned = value

                lambda do
                  Cuprum::Result.new(returned, :errors => errors)
                end # lambda
              end # let

              it 'should return a result', :aggregate_failures do
                result = instance.call

                expect(result).to be_a result_class
                expect(result.value).to be value
                expect(result.errors).to be == implementation_errors
                expect(result.failure?).to be true
              end # it
            end # context
          end # context

          context 'when the operation generates errors' do
            let(:value) { 'returned value'.freeze }
            let(:expected_errors) do
              ['errors.messages.unknown']
            end # let
            let(:implementation) do
              messages = expected_errors
              returned = value

              lambda do
                messages.each do |message|
                  errors << message
                end # each

                returned
              end # lambda
            end # let

            it 'should return a result', :aggregate_failures do
              result = instance.call

              expect(result).to be_a result_class
              expect(result.value).to be value

              expected_errors.each do |message|
                expect(result.errors).to include message
              end # each
            end # it

            context 'when the implementation returns a result' do
              let(:implementation) do
                messages = expected_errors
                returned = value

                lambda do
                  messages.each do |message|
                    errors << message
                  end # each

                  Cuprum::Result.new(returned)
                end # lambda
              end # let

              it 'should return a result', :aggregate_failures do
                result = instance.call

                expect(result).to be_a result_class
                expect(result.value).to be value

                expected_errors.each do |message|
                  expect(result.errors).to include message
                end # each
              end # it
            end # context

            context 'when the implementation returns a result with errors' do
              let(:implementation_errors) do
                ['errors.messages.custom']
              end # let
              let(:implementation) do
                messages = expected_errors
                errors   = implementation_errors
                returned = value

                lambda do
                  messages.each do |message|
                    errors << message
                  end # each

                  Cuprum::Result.new(returned, :errors => errors)
                end # lambda
              end # let

              it 'should return a result', :aggregate_failures do
                result = instance.call

                expect(result).to be_a result_class
                expect(result.value).to be value

                [*expected_errors, *implementation_errors].each do |message|
                  expect(result.errors).to include message
                end # each

                expect(result.failure?).to be true
              end # it
            end # context
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
            to raise_error described_class::NotImplementedError,
              'no implementation defined for function'
        end # it

        wrap_context 'when the function is initialized with a block' do
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

      describe '#chain' do
        include_context 'when the function is initialized with a block'

        let(:called_functions) { [] }
        let(:value)            { 'first value'.freeze }
        let(:expected_value)   { [value] }
        let(:expected_called)  { ['first function'.freeze] }
        let(:conditional)      { nil }
        let(:last_success)     { true }
        let(:implementation) do
          called   = called_functions
          returned = value

          lambda do
            called << 'first function'.freeze

            [returned]
          end # lambda
        end # let

        def chain_function other_function
          if other_function.is_a?(Proc)
            instance.chain(:on => conditional, &other_function)
          else
            instance.chain(other_function, :on => conditional)
          end # if-else
        end # method chain_function

        it 'should define the method' do
          expect(instance).
            to respond_to(:chain).
            with(0..1).arguments.
            and_keywords(:on).
            and_a_block
        end # it

        include_examples 'should chain the function'

        describe 'with :on => :always' do
          let(:conditional) { :always }

          include_examples 'should chain the function'
        end # describe

        describe 'with :on => :failure' do
          let(:conditional) { :failure }

          include_examples 'should chain but not call the function'
        end # describe

        describe 'with :on => :success' do
          let(:conditional) { :success }

          include_examples 'should chain the function'
        end # describe

        wrap_context 'when the function is failing' do
          include_examples 'should chain the function'

          describe 'with :on => :always' do
            let(:conditional) { :always }

            include_examples 'should chain the function'
          end # describe

          describe 'with :on => :failure' do
            let(:conditional) { :failure }

            include_examples 'should chain the function'
          end # describe

          describe 'with :on => :success' do
            let(:conditional) { :success }

            include_examples 'should chain but not call the function'
          end # describe
        end # wrap_context

        wrap_context 'when the function is halted' do
          include_examples 'should chain but not call the function'

          describe 'with :on => :always' do
            let(:conditional) { :always }

            include_examples 'should chain the function'
          end # describe

          describe 'with :on => :failure' do
            let(:conditional) { :failure }

            include_examples 'should chain but not call the function'
          end # describe

          describe 'with :on => :success' do
            let(:conditional) { :success }

            include_examples 'should chain but not call the function'
          end # describe
        end # wrap_context

        wrap_context 'when a previous function is failing' do
          include_examples 'should chain the function'

          describe 'with :on => :always' do
            let(:conditional) { :always }

            include_examples 'should chain the function'
          end # describe

          describe 'with :on => :failure' do
            let(:conditional) { :failure }

            include_examples 'should chain but not call the function'
          end # describe

          describe 'with :on => :success' do
            let(:conditional) { :success }

            include_examples 'should chain the function'
          end # describe
        end # wrap_context

        wrap_context 'when the function has one chained function' do
          include_examples 'should chain the function'
        end # wrap_context

        wrap_context 'when the function has many chained functions' do
          include_examples 'should chain the function'
        end # wrap_context
      end # describe

      describe '#else' do
        include_context 'when the function is initialized with a block'

        let(:called_functions) { [] }
        let(:value)            { 'first value'.freeze }
        let(:expected_value)   { [value] }
        let(:expected_called)  { ['first function'.freeze] }
        let(:last_success)     { true }
        let(:implementation) do
          called   = called_functions
          returned = value

          lambda do
            called << 'first function'.freeze

            [returned]
          end # lambda
        end # let

        def chain_function other_function
          if other_function.is_a?(Proc)
            instance.else(&other_function)
          else
            instance.else(other_function)
          end # if-else
        end # method chain_function

        it 'should define the method' do
          expect(instance).
            to respond_to(:else).
            with(0..1).arguments.
            and_a_block
        end # it

        include_examples 'should chain but not call the function'

        wrap_context 'when the function is failing' do
          include_examples 'should chain the function'
        end # wrap_context

        wrap_context 'when the function is halted' do
          include_examples 'should chain but not call the function'
        end # wrap_context

        wrap_context 'when a previous function is failing' do
          include_examples 'should chain but not call the function'
        end # wrap_context

        wrap_context 'when the function has one chained function' do
          include_examples 'should chain but not call the function'
        end # wrap_context

        wrap_context 'when the function has many chained functions' do
          include_examples 'should chain but not call the function'
        end # wrap_context
      end # describe

      describe '#errors' do
        it 'should define the reader' do
          expect(instance).
            to have_reader(:errors, :allow_private => true).
            with_value(nil)
        end # it

        it { expect(instance.send(:errors)).to be_nil }

        wrap_context 'when the function is executing the implementation' do
          let(:expected_errors) do
            ['errors.messages.unknown']
          end # let

          it 'should be an empty array' do
            call_with_implementation do |instance|
              errors = instance.send(:errors)

              expect(errors).to be_a Array
              expect(errors).to be_empty
            end # call_with_implementation
          end # it

          it 'should update the result errors' do
            result =
              call_with_implementation do |instance|
                expected_errors.each { |msg| instance.send(:errors) << msg }
              end # call_with_implementation

            expected_errors.each do |message|
              expect(result.errors).to include message
            end # each
          end # it

          context 'when the function has a custom #build_errors method' do
            let(:described_class) do
              Class.new(super()) do
                def build_errors
                  Spec::Errors.new
                end # method build_errors
              end # class
            end # let

            example_constant 'Spec::Errors' do
              # rubocop:disable RSpec/InstanceVariable
              Class.new(Delegator) do
                def initialize
                  @errors = []

                  super(@errors)
                end # constructor

                def __getobj__
                  @errors
                end # method

                def __setobj__ ary
                  @errors = ary
                end # method __setobj__
              end # class
              # rubocop:enable RSpec/InstanceVariable
            end # constant

            it 'should be an empty errors object' do
              call_with_implementation do |instance|
                errors = instance.send(:errors)

                expect(errors).to be_a Spec::Errors
                expect(errors).to be_empty
              end # call_with_implementation
            end # it
          end # context
        end # context
      end # describe

      describe '#failure!' do
        it 'should define the private method' do
          expect(instance).not_to respond_to(:failure!)

          expect(instance).to respond_to(:failure!, true).with(0).arguments
        end # it

        it { expect(instance.send(:failure!)).to be_nil }

        wrap_context 'when the function is executing the implementation' do
          it { expect(instance.send(:halt!)).to be_nil }

          it 'should mark the result as failing' do
            result =
              call_with_implementation { |instance| instance.send(:failure!) }

            expect(result.failure?).to be true
          end # it
        end # method wrap_context
      end # describe

      describe '#halt!' do
        it 'should define the private method' do
          expect(instance).not_to respond_to(:halt!)

          expect(instance).to respond_to(:halt!, true).with(0).arguments
        end # it

        it { expect(instance.send(:halt!)).to be_nil }

        wrap_context 'when the function is executing the implementation' do
          it { expect(instance.send(:halt!)).to be_nil }

          it 'should halt the result' do
            result =
              call_with_implementation { |instance| instance.send(:halt!) }

            expect(result.halted?).to be true
          end # it
        end # method wrap_context
      end # describe

      describe '#success!' do
        it 'should define the private method' do
          expect(instance).not_to respond_to(:success!)

          expect(instance).to respond_to(:success!, true).with(0).arguments
        end # it

        it { expect(instance.send(:success!)).to be_nil }

        wrap_context 'when the function is executing the implementation' do
          it { expect(instance.send(:success!)).to be_nil }

          it 'should mark the result as failing' do
            result =
              call_with_implementation do |instance|
                instance.send(:errors) << 'errors.messages.unknown'

                instance.send(:success!)
              end # call_with_implementation

            expect(result.success?).to be true
          end # it
        end # method wrap_context
      end # describe

      describe '#then' do
        include_context 'when the function is initialized with a block'

        let(:called_functions) { [] }
        let(:value)            { 'first value'.freeze }
        let(:expected_value)   { [value] }
        let(:expected_called)  { ['first function'.freeze] }
        let(:last_success)     { true }
        let(:implementation) do
          called   = called_functions
          returned = value

          lambda do
            called << 'first function'.freeze

            [returned]
          end # lambda
        end # let

        def chain_function other_function
          if other_function.is_a?(Proc)
            instance.then(&other_function)
          else
            instance.then(other_function)
          end # if-else
        end # method chain_function

        it 'should define the method' do
          expect(instance).
            to respond_to(:then).
            with(0..1).arguments.
            and_a_block
        end # it

        include_examples 'should chain the function'

        wrap_context 'when the function is failing' do
          include_examples 'should chain but not call the function'
        end # wrap_context

        wrap_context 'when the function is halted' do
          include_examples 'should chain but not call the function'
        end # wrap_context

        wrap_context 'when a previous function is failing' do
          include_examples 'should chain the function'
        end # wrap_context

        wrap_context 'when the function has one chained function' do
          include_examples 'should chain the function'
        end # wrap_context

        wrap_context 'when the function has many chained functions' do
          include_examples 'should chain the function'
        end # wrap_context
      end # describe
    end # shared_examples
  end # module
end # module
