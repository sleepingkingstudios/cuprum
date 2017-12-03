require 'rspec/sleeping_king_studios/concerns/shared_example_group'

require 'cuprum/command'

module Spec::Examples
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
        copy = chained_function

        expect(copy).to be_a described_class
        expect(copy).not_to be instance
      end # it
    end # shared_examples

    shared_examples 'should call each chained function' do
      it 'should call each chained function' do
        chained_function.call

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
            result = chained_function.call

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
            result = chained_function.call

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
            result = chained_function.call

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

            Cuprum::Command.new do |result|
              called << 'last function'.freeze

              result.value << returned
            end # function
          end # let

          include_examples 'should copy the function'

          include_examples 'should call each chained function'

          it 'should return the function result' do
            result = chained_function.call

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
            result = chained_function.call

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
            result = chained_function.call

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
            result = chained_function.call

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
            result = chained_function.call

            expect(result).to be_a result_class
            expect(result.success?).to be last_success
            expect(result.value).to be == expected_value
          end # it
        end # describe

        describe 'with a function' do
          let(:other_function) do
            called   = called_functions
            returned = other_value

            Cuprum::Command.new do |result|
              # :nocov:
              called << 'last function'.freeze

              result.value << returned
              # :nocov:
            end # function
          end # let

          include_examples 'should copy the function'

          include_examples 'should call each chained function'

          it 'should return the previous result' do
            result = chained_function.call

            expect(result).to be_a result_class
            expect(result.success?).to be last_success
            expect(result.value).to be == expected_value
          end # it
        end # describe

        describe 'with an operation' do
          let(:other_function) do
            called   = called_functions
            returned = other_value

            Cuprum::Operation.new do |result|
              # :nocov:
              called << 'last function'.freeze

              result.value << returned
              # :nocov:
            end # function
          end # let

          include_examples 'should copy the function'

          include_examples 'should call each chained function'

          it 'should return the previous result' do
            result = chained_function.call

            expect(result).to be_a result_class
            expect(result.success?).to be last_success
            expect(result.value).to be == expected_value
          end # it
        end # describe
      end # describe
    end # shared_examples

    shared_examples 'should implement the Command chaining methods' do
      describe '#chain' do
        let(:called_functions) { [] }
        let(:other_function)   { ->() {} }
        let(:chained_function) { chain_function(other_function) }
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

        before(:example) do
          allow(chained_function).to receive(:process) do
            chained_function.instance_exec(&implementation)
          end # allow
        end # before example

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
        let(:called_functions) { [] }
        let(:other_function)   { ->() {} }
        let(:chained_function) { chain_function(other_function) }
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

        before(:example) do
          allow(chained_function).to receive(:process) do
            chained_function.instance_exec(&implementation)
          end # allow
        end # before example

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

      describe '#then' do
        let(:called_functions) { [] }
        let(:other_function)   { ->() {} }
        let(:chained_function) { chain_function(other_function) }
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

        before(:example) do
          allow(chained_function).to receive(:process) do
            chained_function.instance_exec(&implementation)
          end # allow
        end # before example

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

      describe '#yield_result' do
        shared_examples 'should call the block' do
          it 'should yield the previous result to the block' do
            expect do |block|
              instance.yield_result(:on => conditional, &block).call
            end.
              to yield_with_args(first_result)
          end # it

          context 'when the block returns a value' do
            it 'should wrap the value in a result' do
              value   = 'final value'.freeze
              chained = instance.yield_result(:on => conditional) { value }
              result  = chained.call

              expect(result).to be_a Cuprum::Result
              expect(result.value).to be value
            end # it
          end # context

          context 'when the block returns an operation' do
            it 'should return the result' do
              result    = Cuprum::Result.new('final value'.freeze)
              operation = Cuprum::Operation.new { result }
              chained   =
                instance.yield_result(:on => conditional) { operation.call }

              expect(chained.call).to be result
            end # it
          end # context

          context 'when the block returns a result' do
            it 'should return the result' do
              result  = Cuprum::Result.new('final value'.freeze)
              chained = instance.yield_result(:on => conditional) { result }

              expect(chained.call).to be result
            end # it
          end # context
        end # shared_examples

        shared_examples 'should not call the block' do
          it 'should not yield to the block' do
            expect do |block|
              instance.yield_result(:on => conditional, &block).call
            end.
              not_to yield_control
          end # it

          it 'should return the previous result' do
            chained = instance.yield_result(:on => conditional) {}

            expect(chained.call).to be first_result
          end # it
        end # shared_examples

        let(:first_result)  { Cuprum::Result.new('first value'.freeze) }
        let(:chained_block) { ->() {} }
        let(:conditional)   { nil }

        before(:example) do
          allow(instance).to receive(:process).and_return(first_result)
        end # before example

        it 'should define the method' do
          expect(instance).
            to respond_to(:yield_result).
            with(0).arguments.
            and_keywords(:on).
            and_a_block
        end # it

        it 'should clone the command' do
          chained = instance.yield_result(:on => conditional) {}

          expect(chained).to be_a described_class
          expect(chained).not_to be instance
        end # it

        include_examples 'should call the block'

        describe 'with :on => :always' do
          let(:conditional) { :always }

          include_examples 'should call the block'
        end # describe

        describe 'with :on => :failure' do
          let(:conditional) { :failure }

          include_examples 'should not call the block'
        end # describe

        describe 'with :on => :success' do
          let(:conditional) { :success }

          include_examples 'should call the block'
        end # describe

        context 'when the previous result is failing' do
          let(:first_result) { super().failure! }

          include_examples 'should call the block'

          describe 'with :on => :always' do
            let(:conditional) { :always }

            include_examples 'should call the block'
          end # describe

          describe 'with :on => :failure' do
            let(:conditional) { :failure }

            include_examples 'should call the block'
          end # describe

          describe 'with :on => :success' do
            let(:conditional) { :success }

            include_examples 'should not call the block'
          end # describe
        end # context

        context 'when the previous result is halted' do
          let(:first_result) { super().halt! }

          include_examples 'should not call the block'

          describe 'with :on => :always' do
            let(:conditional) { :always }

            include_examples 'should call the block'
          end # describe

          describe 'with :on => :failure' do
            let(:conditional) { :failure }

            include_examples 'should not call the block'
          end # describe

          describe 'with :on => :success' do
            let(:conditional) { :success }

            include_examples 'should not call the block'
          end # describe
        end # context

        context 'when multiple results are yielded' do
          let(:results) do
            %w[first second third].
              map { |str| "#{str} value".freeze }.
              map { |str| Cuprum::Result.new(str) }
          end # let
          let(:chained) do
            instance.
              yield_result do |result|
                yielded << result
                results[0]
              end.
              yield_result do |result|
                yielded << result
                results[1]
              end.
              yield_result do |result|
                yielded << result
                results[2]
              end
          end # let
          let(:yielded) { [] }

          it 'should yield each result to the next block' do
            chained.call

            expect(yielded).to be == [first_result, results[0], results[1]]
          end # it

          it 'should return the final result' do
            expect(chained.call).to be results.last
          end # it
        end # context
      end # describe
    end # shared_examples
  end # module
end # module
