require 'rspec/sleeping_king_studios/concerns/shared_example_group'

require 'cuprum/command'

module Spec::Examples
  module ChainingExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    module ChainMethodExamples
      extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

      shared_context 'with a block' do
        shared_examples 'should call the block with the previous result value' \
        do
          it 'should call the block with the previous result value' do
            expect do |block|
              chain_block(&block).call
            end.
              to yield_with_args(first_value)
          end # it
        end # shared_examples

        shared_examples 'should not call the block with any args' do
          it 'should not call the block with any args' do
            expect do |block|
              chain_block(&block).call
            end.
              not_to yield_control
          end # it
        end # shared_examples

        let(:chained) { chain_block(&chained_implementation) }
      end # shared_context

      shared_context 'with a command' do
        shared_examples 'should call the block with the previous result value' \
        do
          context 'when the chained implementation takes no arguments' do
            let(:chained_implementation) { ->() {} }
            let!(:chained)               { super() }

            it 'should call the block with the no arguments' do
              allow(chained_command).to receive(:process)

              chained.call

              expect(chained_command).to have_received(:process).with(no_args)
            end # it
          end # context

          context 'when the chained implementation takes at least one argument'\
          do
            let(:chained_implementation) { ->(_) {} }
            let!(:chained)               { super() }

            it 'should call the block with the previous result value' do
              allow(chained_command).to receive(:process)

              chained.call

              expect(chained_command).
                to have_received(:process).
                with(first_value)
            end # it
          end # context
        end # shared_examples

        shared_examples 'should not call the block with any args' do
          it 'should not call the block with any args' do
            allow(chained_command).to receive(:process)

            chained.call

            expect(chained_command).not_to have_received(:process)
          end # it
        end # shared_examples

        let(:chained_command) do
          Cuprum::Command.new(&chained_implementation)
        end # let
        let(:chained) { chain_command(chained_command) }
      end # shared_context

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

            ->() { value }
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

            ->() { ary.each { |error| result.errors << error } }
          end # let

          it 'should set the errors of the result' do
            result = chained.call

            expected_errors.each do |error|
              expect(result.errors).to include error
            end # each
          end # it
        end # describe

        describe 'when the block sets the result status' do
          let(:chained_implementation) { ->() { result.failure! } }

          it 'should set the status of the result' do
            result = chained.call

            expect(result.failure?).to be true
          end # it
        end # describe

        describe 'when the block halts the result' do
          let(:chained_implementation) { ->() { halt! } }

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

        include_examples 'should not call the block with any args'

        describe 'when the block returns a value' do
          let(:expected_value) { 'last value'.freeze }
          let(:chained_implementation) do
            value = expected_value

            ->() { value }
          end # let

          it 'should not change the value of the result' do
            result = chained.call

            expect(result.value).to be == first_value
          end # it
        end # describe
      end # shared_examples
    end # module

    shared_examples 'should implement the Command chaining methods' do
      describe '#chain' do
        include ChainMethodExamples

        let(:first_value)  { 'first value'.freeze }
        let(:first_result) { Cuprum::Result.new(first_value) }
        let(:conditional)  { nil }
        let(:chained_implementation) do
          ->() {}
        end # let

        before(:example) do
          allow(instance).to receive(:process).and_return(first_result)
        end # before example

        def chain_block &block
          instance.chain(:on => conditional, &block)
        end # method chain_block

        def chain_command command
          instance.chain(command, :on => conditional)
        end # method chain_command

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

        wrap_context 'with a block' do
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
        end # wrap_context

        wrap_context 'with a command' do
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
        end # wrap_context
      end # describe

      describe '#failure' do
        include ChainMethodExamples

        let(:first_value)  { 'first value'.freeze }
        let(:first_result) { Cuprum::Result.new(first_value) }
        let(:conditional)  { nil }
        let(:chained_implementation) do
          ->() {}
        end # let

        before(:example) do
          allow(instance).to receive(:process).and_return(first_result)
        end # before example

        def chain_block &block
          instance.failure(&block)
        end # method chain_block

        def chain_command command
          instance.failure(command)
        end # method chain_command

        it 'should define the method' do
          expect(instance).
            to respond_to(:failure).
            with(0..1).arguments.
            and_a_block
        end # it

        it 'should clone the command' do
          chained = instance.failure {}

          expect(chained).to be_a described_class
          expect(chained).not_to be instance
        end # it

        wrap_context 'with a block' do
          include_examples 'should not call the block'

          context 'when the previous result is failing' do
            let(:first_result) { super().failure! }

            include_examples 'should call the block'
          end # context

          context 'when the previous result is halted' do
            let(:first_result) { super().halt! }

            include_examples 'should not call the block'
          end # context
        end # wrap_context

        wrap_context 'with a command' do
          include_examples 'should not call the block'

          context 'when the previous result is failing' do
            let(:first_result) { super().failure! }

            include_examples 'should call the block'
          end # context

          context 'when the previous result is halted' do
            let(:first_result) { super().halt! }

            include_examples 'should not call the block'
          end # context
        end # wrap_context
      end # describe

      describe '#success' do
        include ChainMethodExamples

        let(:first_value)  { 'first value'.freeze }
        let(:first_result) { Cuprum::Result.new(first_value) }
        let(:conditional)  { nil }
        let(:chained_implementation) do
          ->() {}
        end # let

        before(:example) do
          allow(instance).to receive(:process).and_return(first_result)
        end # before example

        def chain_block &block
          instance.success(&block)
        end # method chain_block

        def chain_command command
          instance.success(command)
        end # method chain_command

        it 'should define the method' do
          expect(instance).
            to respond_to(:success).
            with(0..1).arguments.
            and_a_block
        end # it

        it 'should clone the command' do
          chained = instance.success {}

          expect(chained).to be_a described_class
          expect(chained).not_to be instance
        end # it

        wrap_context 'with a block' do
          include_examples 'should call the block'

          context 'when the previous result is failing' do
            let(:first_result) { super().failure! }

            include_examples 'should not call the block'
          end # context

          context 'when the previous result is halted' do
            let(:first_result) { super().halt! }

            include_examples 'should not call the block'
          end # context
        end # wrap_context

        wrap_context 'with a command' do
          include_examples 'should call the block'

          context 'when the previous result is failing' do
            let(:first_result) { super().failure! }

            include_examples 'should not call the block'
          end # context

          context 'when the previous result is halted' do
            let(:first_result) { super().halt! }

            include_examples 'should not call the block'
          end # context
        end # wrap_context
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
