require 'rspec/sleeping_king_studios/concerns/shared_example_group'

module Spec::Examples
  module FunctionExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    module ChainingExamples
      extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

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

          describe 'with an operation' do
            let(:expected_value) { super() << other_value }
            let(:other_function) do
              called   = called_functions
              returned = other_value

              Cuprum::Operation.new do |result|
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
    end # module

    shared_examples 'should implement the Function methods' do
      describe '#chain' do
        shared_examples 'should chain and call the function' do
          it 'should chain and call the operation' do
            allow(chained).to receive(:process)
            allow(other_function).to receive(:call)

            chained.call

            expect(other_function).to have_received(:call)
          end # it
        end # shared_examples

        shared_examples 'should chain but not call the function' do
          it 'should chain but not call the operation' do
            allow(chained).to receive(:process)
            allow(other_function).to receive(:call)

            chained.call

            expect(other_function).not_to have_received(:call)
          end # it
        end # shared_examples

        let(:conditional) { nil }

        it 'should define the method' do
          expect(instance).
            to respond_to(:chain).
            with(0..1).arguments.
            and_keywords(:on).
            and_a_block
        end # it

        describe 'with a block' do
          let(:other_function) { ->() {} }
          let(:chained) do
            instance.chain(:on => conditional, &other_function)
          end # let

          include_examples 'should chain and call the function'
        end # describe

        describe 'with a function' do
          let(:other_function) { Cuprum::Function.new }
          let(:chained) do
            instance.chain(other_function, :on => conditional)
          end # let

          include_examples 'should chain and call the function'
        end # describe

        describe 'with an operation' do
          let(:other_function) { Cuprum::Operation.new }
          let(:chained) do
            instance.chain(other_function, :on => conditional)
          end # let

          include_examples 'should chain and call the function'
        end # describe

        describe 'with :on => :always' do
          let(:conditional) { :always }

          describe 'with a block' do
            let(:other_function) { ->() {} }
            let(:chained) do
              instance.chain(:on => conditional, &other_function)
            end # let

            include_examples 'should chain and call the function'
          end # describe

          describe 'with a function' do
            let(:other_function) { Cuprum::Function.new }
            let(:chained) do
              instance.chain(other_function, :on => conditional)
            end # let

            include_examples 'should chain and call the function'
          end # describe

          describe 'with an operation' do
            let(:other_function) { Cuprum::Operation.new }
            let(:chained) do
              instance.chain(other_function, :on => conditional)
            end # let

            include_examples 'should chain and call the function'
          end # describe
        end # describe

        describe 'with :on => :failure' do
          let(:conditional) { :failure }

          describe 'with a block' do
            let(:other_function) { ->() {} }
            let(:chained) do
              instance.chain(:on => conditional, &other_function)
            end # let

            include_examples 'should chain but not call the function'
          end # describe

          describe 'with a function' do
            let(:other_function) { Cuprum::Function.new }
            let(:chained) do
              instance.chain(other_function, :on => conditional)
            end # let

            include_examples 'should chain but not call the function'
          end # describe

          describe 'with an operation' do
            let(:other_function) { Cuprum::Operation.new }
            let(:chained) do
              instance.chain(other_function, :on => conditional)
            end # let

            include_examples 'should chain but not call the function'
          end # describe
        end # describe

        describe 'with :on => :success' do
          let(:conditional) { :success }

          describe 'with a block' do
            let(:other_function) { ->() {} }
            let(:chained) do
              instance.chain(:on => conditional, &other_function)
            end # let

            include_examples 'should chain and call the function'
          end # describe

          describe 'with a function' do
            let(:other_function) { Cuprum::Function.new }
            let(:chained) do
              instance.chain(other_function, :on => conditional)
            end # let

            include_examples 'should chain and call the function'
          end # describe

          describe 'with an operation' do
            let(:other_function) { Cuprum::Operation.new }
            let(:chained) do
              instance.chain(other_function, :on => conditional)
            end # let

            include_examples 'should chain and call the function'
          end # describe
        end # describe
      end # describe

      describe '#else' do
        it 'should define the method' do
          expect(instance).
            to respond_to(:else).
            with(0..1).arguments.
            and_a_block
        end # it

        describe 'with a block' do
          let(:other_function) { ->() {} }

          it 'should chain the block on failure' do
            allow(instance).to receive(:chain)

            instance.else(&other_function)

            expect(instance).
              to have_received(:chain) do |function, on:, &block|
                expect(function).to be nil
                expect(on).to be == :failure
                expect(block).to be other_function
              end # have_received
          end # it
        end # describe

        describe 'with a function' do
          let(:other_function) { Cuprum::Function.new }

          it 'should chain the operation on failure' do
            allow(instance).to receive(:chain)

            instance.else(other_function)

            expect(instance).
              to have_received(:chain).
              with(other_function, :on => :failure)
          end # it
        end # describe

        describe 'with an operation' do
          let(:other_function) { Cuprum::Operation.new }

          it 'should chain the operation on failure' do
            allow(instance).to receive(:chain)

            instance.else(other_function)

            expect(instance).
              to have_received(:chain).
              with(other_function, :on => :failure)
          end # it
        end # describe
      end # describe

      describe '#then' do
        it 'should define the method' do
          expect(instance).
            to respond_to(:then).
            with(0..1).arguments.
            and_a_block
        end # it

        describe 'with a block' do
          let(:other_function) { ->() {} }

          it 'should chain the block on success' do
            allow(instance).to receive(:chain)

            instance.then(&other_function)

            expect(instance).
              to have_received(:chain) do |function, on:, &block|
                expect(function).to be nil
                expect(on).to be == :success
                expect(block).to be other_function
              end # have_received
          end # it
        end # describe

        describe 'with a function' do
          let(:other_function) { Cuprum::Function.new }

          it 'should chain the function on success' do
            allow(instance).to receive(:chain)

            instance.then(other_function)

            expect(instance).
              to have_received(:chain).
              with(other_function, :on => :success)
          end # it
        end # describe

        describe 'with an operation' do
          let(:other_function) { Cuprum::Operation.new }

          it 'should chain the operation on success' do
            allow(instance).to receive(:chain)

            instance.then(other_function)

            expect(instance).
              to have_received(:chain).
              with(other_function, :on => :success)
          end # it
        end # describe
      end # describe
    end # shared_examples

    shared_examples 'should implement the generic Function methods' do
      describe '#chain' do
        include ChainingExamples

        include_context 'when the command is initialized with a block'

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
        include ChainingExamples

        include_context 'when the command is initialized with a block'

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

      describe '#then' do
        include ChainingExamples

        include_context 'when the command is initialized with a block'

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
