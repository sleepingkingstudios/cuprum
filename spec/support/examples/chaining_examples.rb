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
        shared_examples 'should call the block' do
          it 'should return the previous result' do
            result = chained.call

            expect(result).to be first_result
          end # it

          include_examples \
            'should call the block with the previous result value'

          describe 'when the block returns a value' do
            let(:expected_value) { 'last value'.freeze }
            let(:chained_implementation) do
              value = expected_value

              ->(_) { value }
            end # let

            it 'should set the value of the result' do
              result = chained.call

              expect(result.value).to be == expected_value
            end # it
          end # describe

          describe 'when the block sets an error' do
            let(:expected_errors) do
              ['errors.messages.unknown']
            end # let
            let(:chained_implementation) do
              ary = expected_errors

              ->(_) { ary.each { |error| errors << error } }
            end # let

            it 'should set the errors of the result' do
              result = chained.call

              expected_errors.each do |error|
                expect(result.errors).to include error
              end # each
            end # it
          end # describe

          describe 'when the block sets the result status' do
            let(:chained_implementation) { ->(_) { failure! } }

            it 'should set the status of the result' do
              result = chained.call

              expect(result.failure?).to be true
            end # it
          end # describe

          describe 'when the block halts the result' do
            let(:chained_implementation) { ->(_) { halt! } }

            it 'should set the status of the result' do
              result = chained.call

              expect(result.halted?).to be true
            end # it
          end # describe
        end # shared_examples

        shared_examples 'should not call the block' do
          it 'should return the previous result' do
            result = chained.call

            expect(result).to be first_result
          end # it

          include_examples 'should not call the block'

          describe 'when the block returns a value' do
            let(:expected_value) { 'last value'.freeze }
            let(:chained_implementation) do
              value = expected_value

              ->(_) { value }
            end # let

            it 'should not change the value of the result' do
              result = chained.call

              expect(result.value).to be == first_value
            end # it
          end # describe
        end # shared_examples

        let(:first_value)  { 'first value'.freeze }
        let(:first_result) { Cuprum::Result.new(first_value) }
        let(:conditional)  { nil }
        let(:chained_implementation) do
          ->(_) {}
        end # let

        before(:example) do
          allow(instance).to receive(:process).and_return(first_result)
        end # before example

        it 'should define the method' do
          expect(instance).
            to respond_to(:chain).
            with(0..1).arguments.
            and_keywords(:on).
            and_a_block
        end # it

        it 'should clone the command' do
          chained = instance.chain(:on => conditional) {}

          expect(chained).to be_a described_class
          expect(chained).not_to be instance
        end # it

        describe 'with a block' do
          shared_examples 'should call the block with the previous result ' \
                          'value' do
            it 'should call the block with the previous result value' do
              expect do |block|
                instance.chain(:on => conditional, &block).call
              end.
                to yield_with_args(first_value)
            end # it
          end # shared_examples

          shared_examples 'should not call the block' do
            it 'should not call the block' do
              expect do |block|
                instance.chain(:on => conditional, &block).call
              end.
                not_to yield_control
            end # it
          end # shared_examples

          let(:chained) do
            instance.chain(:on => conditional, &chained_implementation)
          end # let

          it 'should call the block with the previous result value' do
            expect do |block|
              instance.chain(:on => conditional, &block).call
            end.
              to yield_with_args(first_value)
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

          context 'when multiple blocks are chained' do
            let(:values) do
              %w[second third fourth].map { |str| "#{str} value".freeze }
            end # let
            let(:blocks) do
              ary = arguments

              values.map do |value|
                lambda do |arg|
                  ary << arg

                  value
                end # lambda
              end # results
            end # let
            let(:chained) do
              instance.
                chain(&blocks[0]).
                chain(&blocks[1]).
                chain(&blocks[2])
            end # let
            let(:arguments) { [] }

            it 'should call each command with the previous result value' do
              chained.call

              expect(arguments).to be == [first_value, values[0], values[1]]
            end # it

            it 'should return the first result' do
              expect(chained.call).to be first_result
            end # it

            it 'should set the value of the result' do
              result = chained.call

              expect(result.value).to be == values.last
            end # it
          end # context
        end # describe

        describe 'with a command' do
          shared_examples 'should call the block with the previous result ' \
                          'value' do
            it 'should call the block with the previous result value' do
              allow(chained_command).to receive(:process)

              chained.call

              expect(chained_command).
                to have_received(:process).
                with(first_value)
            end # it
          end # shared_examples

          shared_examples 'should not call the block' do
            it 'should not call the block' do
              allow(chained_command).to receive(:process)

              chained.call

              expect(chained_command).not_to have_received(:process)
            end # it
          end # shared_examples

          let(:chained_command) do
            Cuprum::Command.new(&chained_implementation)
          end # let
          let(:chained) do
            instance.chain(chained_command, :on => conditional)
          end # let

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

          context 'when multiple commands are chained' do
            let(:values) do
              %w[second third fourth].map { |str| "#{str} value".freeze }
            end # let
            let(:commands) do
              ary = arguments

              values.map do |value|
                Cuprum::Command.new do |arg|
                  ary << arg

                  value
                end # command
              end # results
            end # let
            let(:chained) do
              instance.
                chain(commands[0]).
                chain(commands[1]).
                chain(commands[2])
            end # let
            let(:arguments) { [] }

            it 'should call each command with the previous result value' do
              chained.call

              expect(arguments).to be == [first_value, values[0], values[1]]
            end # it

            it 'should return the first result' do
              expect(chained.call).to be first_result
            end # it

            it 'should set the value of the result' do
              result = chained.call

              expect(result.value).to be == values.last
            end # it
          end # context
        end # describe
      end # describe

      describe '#tap_result' do
        shared_examples 'should call the block' do
          it 'should yield the previous result to the block' do
            expect do |block|
              instance.tap_result(:on => conditional, &block).call
            end.
              to yield_with_args(first_result)
          end # it

          it 'should return the previous result' do
            value   = 'final value'.freeze
            chained = instance.tap_result(:on => conditional) { value }

            expect(chained.call).to be first_result
          end # it
        end # shared_examples

        shared_examples 'should not call the block' do
          it 'should not yield to the block' do
            expect do |block|
              instance.tap_result(:on => conditional, &block).call
            end.
              not_to yield_control
          end # it

          it 'should return the previous result' do
            chained = instance.tap_result(:on => conditional) {}

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
            to respond_to(:tap_result).
            with(0).arguments.
            and_keywords(:on).
            and_a_block
        end # it

        it 'should clone the command' do
          chained = instance.tap_result(:on => conditional) {}

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

        context 'when multiple results are tapped' do
          let(:results) do
            %w[second third fourth].
              map { |str| "#{str} value".freeze }.
              map { |str| Cuprum::Result.new(str) }
          end # let
          let(:chained) do
            instance.
              tap_result do |result|
                yielded << result
                results[0]
              end.
              tap_result do |result|
                yielded << result
                results[1]
              end.
              tap_result do |result|
                yielded << result
                results[2]
              end
          end # let
          let(:yielded) { [] }

          it 'should yield the first result to each block' do
            chained.call

            expect(yielded).to be == Array.new(3) { first_result }
          end # it

          it 'should return the first result' do
            expect(chained.call).to be first_result
          end # it
        end # context
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
            %w[second third fourth].
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
