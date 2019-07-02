# frozen_string_literal: true

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
          end
        end

        shared_examples 'should not call the block with any args' do
          it 'should not call the block with any args' do
            expect do |block|
              chain_block(&block).call
            end.
              not_to yield_control
          end
        end

        let(:chained) { chain_block(&chained_implementation) }
      end

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
            end
          end

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
            end
          end
        end

        shared_examples 'should not call the block with any args' do
          it 'should not call the block with any args' do
            allow(chained_command).to receive(:process)

            chained.call

            expect(chained_command).not_to have_received(:process)
          end
        end

        let(:chained_command) do
          Cuprum::Command.new(&chained_implementation)
        end
        let(:chained) { chain_command(chained_command) }
      end

      shared_examples 'should call the block' do
        let(:result) { chained.call.to_cuprum_result }

        it 'should return the previous result' do
          expect(result).to be first_result
        end

        include_examples \
          'should call the block with the previous result value'

        describe 'when the block returns a value' do
          let(:expected_value) { 'last value' }
          let(:chained_implementation) do
            value = expected_value

            ->() { value }
          end

          it 'should set the value of the result' do
            expect(result.value).to be == expected_value
          end
        end

        describe 'when the block sets an error' do
          let(:expected_errors) do
            ['errors.messages.unknown']
          end
          let(:chained_implementation) do
            ary = expected_errors

            ->() { ary.each { |error| result.errors << error } }
          end

          it 'should set the errors of the result' do
            expected_errors.each do |error|
              expect(result.errors).to include error
            end
          end
        end
      end

      shared_examples 'should not call the block' do
        let(:result) { chained.call.to_cuprum_result }

        it 'should return the previous result' do
          expect(result).to be first_result
        end

        include_examples 'should not call the block with any args'

        describe 'when the block returns a value' do
          let(:expected_value) { 'last value' }
          let(:chained_implementation) do
            value = expected_value

            ->() { value }
          end

          it 'should not change the value of the result' do
            expect(result.value).to be == first_value
          end
        end
      end
    end

    shared_examples 'should implement the Chaining methods' do
      describe '#chain' do
        include ChainMethodExamples

        let(:first_value)  { 'first value' }
        let(:first_errors) { ['first error'] }
        let(:first_result) { Cuprum::Result.new(value: first_value) }
        let(:conditional)  { nil }
        let(:chained_implementation) do
          ->() {}
        end

        before(:example) do
          allow(instance).to receive(:process).and_return(first_result)
        end

        def chain_block &block
          instance.chain(on: conditional, &block)
        end

        def chain_command command
          instance.chain(command, on: conditional)
        end

        it 'should define the method' do
          expect(instance).
            to respond_to(:chain).
            with(0..1).arguments.
            and_keywords(:on).
            and_a_block
        end

        it 'should clone the command' do
          chained = instance.chain(on: conditional) {}

          expect(chained).to be_a described_class
          expect(chained).not_to be instance
        end

        wrap_context 'with a block' do
          include_examples 'should call the block'

          describe 'with on: :always' do
            let(:conditional) { :always }

            include_examples 'should call the block'
          end

          describe 'with on: :failure' do
            let(:conditional) { :failure }

            include_examples 'should not call the block'
          end

          describe 'with on: :success' do
            let(:conditional) { :success }

            include_examples 'should call the block'
          end

          context 'when the previous result is failing' do
            let(:first_result) do
              Cuprum::Result.new(value: first_value, errors: first_errors)
            end

            include_examples 'should call the block'

            describe 'with on: :always' do
              let(:conditional) { :always }

              include_examples 'should call the block'
            end

            describe 'with on: :failure' do
              let(:conditional) { :failure }

              include_examples 'should call the block'
            end

            describe 'with on: :success' do
              let(:conditional) { :success }

              include_examples 'should not call the block'
            end
          end

          context 'when multiple blocks are chained' do
            let(:values) do
              %w[second third fourth].map { |str| "#{str} value" }
            end
            let(:blocks) do
              ary = arguments

              values.map do |value|
                lambda do |arg|
                  ary << arg

                  value
                end
              end
            end
            let(:chained) do
              instance.
                chain(&blocks[0]).
                chain(&blocks[1]).
                chain(&blocks[2])
            end
            let(:arguments) { [] }
            let(:result)    { chained.call.to_cuprum_result }

            it 'should call each command with the previous result value' do
              chained.call

              expect(arguments).to be == [first_value, values[0], values[1]]
            end

            it 'should return the first result' do
              expect(result).to be first_result
            end

            it 'should set the value of the result' do
              expect(result.value).to be == values.last
            end
          end
        end

        wrap_context 'with a command' do
          include_examples 'should call the block'

          describe 'with on: :always' do
            let(:conditional) { :always }

            include_examples 'should call the block'
          end

          describe 'with on: :failure' do
            let(:conditional) { :failure }

            include_examples 'should not call the block'
          end

          describe 'with on: :success' do
            let(:conditional) { :success }

            include_examples 'should call the block'
          end

          context 'when the previous result is failing' do
            let(:first_result) do
              Cuprum::Result.new(value: first_value, errors: first_errors)
            end

            include_examples 'should call the block'

            describe 'with on: :always' do
              let(:conditional) { :always }

              include_examples 'should call the block'
            end

            describe 'with on: :failure' do
              let(:conditional) { :failure }

              include_examples 'should call the block'
            end

            describe 'with on: :success' do
              let(:conditional) { :success }

              include_examples 'should not call the block'
            end
          end

          context 'when multiple commands are chained' do
            let(:values) do
              %w[second third fourth].map { |str| "#{str} value" }
            end
            let(:commands) do
              ary = arguments

              values.map do |value|
                Cuprum::Command.new do |arg|
                  ary << arg

                  value
                end
              end
            end
            let(:chained) do
              instance.
                chain(commands[0]).
                chain(commands[1]).
                chain(commands[2])
            end
            let(:arguments) { [] }
            let(:result)    { chained.call.to_cuprum_result }

            it 'should call each command with the previous result value' do
              chained.call

              expect(arguments).to be == [first_value, values[0], values[1]]
            end

            it 'should return the first result' do
              expect(result).to be first_result
            end

            it 'should set the value of the result' do
              expect(result.value).to be == values.last
            end
          end
        end
      end

      describe '#chain!' do
        include ChainMethodExamples

        let(:first_value)  { 'first value' }
        let(:first_errors) { ['first error'] }
        let(:first_result) { Cuprum::Result.new(value: first_value) }
        let(:conditional)  { nil }
        let(:chained_implementation) do
          ->() {}
        end

        before(:example) do
          allow(instance).to receive(:process).and_return(first_result)
        end

        def chain_block &block
          instance.send(:chain!, on: conditional, &block)
        end

        def chain_command command
          instance.send(:chain!, command, on: conditional)
        end

        it 'should define the method' do
          expect(instance).
            to respond_to(:chain!, true).
            with(0..1).arguments.
            and_keywords(:on).
            and_a_block
        end

        it 'should return the command' do
          chained = instance.send(:chain!, on: conditional) {}

          expect(chained).to be instance
        end

        wrap_context 'with a block' do
          include_examples 'should call the block'

          describe 'with on: :always' do
            let(:conditional) { :always }

            include_examples 'should call the block'
          end

          describe 'with on: :failure' do
            let(:conditional) { :failure }

            include_examples 'should not call the block'
          end

          describe 'with on: :success' do
            let(:conditional) { :success }

            include_examples 'should call the block'
          end

          context 'when the previous result is failing' do
            let(:first_result) do
              Cuprum::Result.new(value: first_value, errors: first_errors)
            end

            include_examples 'should call the block'

            describe 'with on: :always' do
              let(:conditional) { :always }

              include_examples 'should call the block'
            end

            describe 'with on: :failure' do
              let(:conditional) { :failure }

              include_examples 'should call the block'
            end

            describe 'with on: :success' do
              let(:conditional) { :success }

              include_examples 'should not call the block'
            end
          end

          context 'when multiple blocks are chained' do
            let(:values) do
              %w[second third fourth].map { |str| "#{str} value" }
            end
            let(:blocks) do
              ary = arguments

              values.map do |value|
                lambda do |arg|
                  ary << arg

                  value
                end
              end
            end
            let(:chained) do
              instance.
                chain(&blocks[0]).
                chain(&blocks[1]).
                chain(&blocks[2])
            end
            let(:arguments) { [] }
            let(:result)    { chained.call.to_cuprum_result }

            it 'should call each command with the previous result value' do
              chained.call

              expect(arguments).to be == [first_value, values[0], values[1]]
            end

            it 'should return the first result' do
              expect(result).to be first_result
            end

            it 'should set the value of the result' do
              expect(result.value).to be == values.last
            end
          end
        end

        wrap_context 'with a command' do
          include_examples 'should call the block'

          describe 'with on: :always' do
            let(:conditional) { :always }

            include_examples 'should call the block'
          end

          describe 'with on: :failure' do
            let(:conditional) { :failure }

            include_examples 'should not call the block'
          end

          describe 'with on: :success' do
            let(:conditional) { :success }

            include_examples 'should call the block'
          end

          context 'when the previous result is failing' do
            let(:first_result) do
              Cuprum::Result.new(value: first_value, errors: first_errors)
            end

            include_examples 'should call the block'

            describe 'with on: :always' do
              let(:conditional) { :always }

              include_examples 'should call the block'
            end

            describe 'with on: :failure' do
              let(:conditional) { :failure }

              include_examples 'should call the block'
            end

            describe 'with on: :success' do
              let(:conditional) { :success }

              include_examples 'should not call the block'
            end
          end

          context 'when multiple commands are chained' do
            let(:values) do
              %w[second third fourth].map { |str| "#{str} value" }
            end
            let(:commands) do
              ary = arguments

              values.map do |value|
                Cuprum::Command.new do |arg|
                  ary << arg

                  value
                end
              end
            end
            let(:chained) do
              instance.
                chain(commands[0]).
                chain(commands[1]).
                chain(commands[2])
            end
            let(:arguments) { [] }
            let(:result)    { chained.call.to_cuprum_result }

            it 'should call each command with the previous result value' do
              chained.call

              expect(arguments).to be == [first_value, values[0], values[1]]
            end

            it 'should return the first result' do
              expect(result).to be first_result
            end

            it 'should set the value of the result' do
              expect(result.value).to be == values.last
            end
          end
        end
      end

      describe '#tap_result' do
        shared_examples 'should call the block' do
          it 'should yield the previous result to the block' do
            expect do |block|
              instance.tap_result(on: conditional, &block).call
            end.
              to yield_with_args(first_result)
          end

          it 'should return the previous result' do
            value   = 'final value'
            chained = instance.tap_result(on: conditional) { value }

            expect(chained.call.to_cuprum_result).to be first_result
          end
        end

        shared_examples 'should not call the block' do
          it 'should not yield to the block' do
            expect do |block|
              instance.tap_result(on: conditional, &block).call
            end.
              not_to yield_control
          end

          it 'should return the previous result' do
            chained = instance.tap_result(on: conditional) {}

            expect(chained.call.to_cuprum_result).to be first_result
          end
        end

        let(:first_value)   { 'first value' }
        let(:first_errors)  { ['first error'] }
        let(:first_result)  { Cuprum::Result.new(value: first_value) }
        let(:chained_block) { ->() {} }
        let(:conditional)   { nil }

        before(:example) do
          allow(instance).to receive(:process).and_return(first_result)
        end

        it 'should define the method' do
          expect(instance).
            to respond_to(:tap_result).
            with(0).arguments.
            and_keywords(:on).
            and_a_block
        end

        it 'should clone the command' do
          chained = instance.tap_result(on: conditional) {}

          expect(chained).to be_a described_class
          expect(chained).not_to be instance
        end

        include_examples 'should call the block'

        describe 'with on: :always' do
          let(:conditional) { :always }

          include_examples 'should call the block'
        end

        describe 'with on: :failure' do
          let(:conditional) { :failure }

          include_examples 'should not call the block'
        end

        describe 'with on: :success' do
          let(:conditional) { :success }

          include_examples 'should call the block'
        end

        context 'when the previous result is failing' do
          let(:first_result) do
            Cuprum::Result.new(value: first_value, errors: first_errors)
          end

          include_examples 'should call the block'

          describe 'with on: :always' do
            let(:conditional) { :always }

            include_examples 'should call the block'
          end

          describe 'with on: :failure' do
            let(:conditional) { :failure }

            include_examples 'should call the block'
          end

          describe 'with on: :success' do
            let(:conditional) { :success }

            include_examples 'should not call the block'
          end
        end

        context 'when multiple results are tapped' do
          let(:results) do
            %w[second third fourth].
              map { |str| "#{str} value" }.
              map { |str| Cuprum::Result.new(value: str) }
          end
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
          end
          let(:yielded) { [] }

          it 'should yield the first result to each block' do
            chained.call

            expect(yielded).to be == Array.new(3) { first_result }
          end

          it 'should return the first result' do
            expect(chained.call.to_cuprum_result).to be first_result
          end
        end
      end

      describe '#tap_result!' do
        shared_examples 'should call the block' do
          it 'should yield the previous result to the block' do
            expect do |block|
              instance.send(:tap_result!, on: conditional, &block).call
            end.
              to yield_with_args(first_result)
          end

          it 'should return the previous result' do
            value   = 'final value'
            chained = instance.send(:tap_result!, on: conditional) { value }

            expect(chained.call.to_cuprum_result).to be first_result
          end
        end

        shared_examples 'should not call the block' do
          it 'should not yield to the block' do
            expect do |block|
              instance.send(:tap_result!, on: conditional, &block).call
            end.
              not_to yield_control
          end

          it 'should return the previous result' do
            chained = instance.send(:tap_result!, on: conditional) {}

            expect(chained.call.to_cuprum_result).to be first_result
          end
        end

        let(:first_value)   { 'first value' }
        let(:first_errors)  { ['first error'] }
        let(:first_result)  { Cuprum::Result.new(value: first_value) }
        let(:chained_block) { ->() {} }
        let(:conditional)   { nil }

        before(:example) do
          allow(instance).to receive(:process).and_return(first_result)
        end

        it 'should define the method' do
          expect(instance).
            to respond_to(:tap_result!, true).
            with(0).arguments.
            and_keywords(:on).
            and_a_block
        end

        it 'should return the command' do
          chained = instance.send(:tap_result!, on: conditional) {}

          expect(chained).to be instance
        end

        include_examples 'should call the block'

        describe 'with on: :always' do
          let(:conditional) { :always }

          include_examples 'should call the block'
        end

        describe 'with on: :failure' do
          let(:conditional) { :failure }

          include_examples 'should not call the block'
        end

        describe 'with on: :success' do
          let(:conditional) { :success }

          include_examples 'should call the block'
        end

        context 'when the previous result is failing' do
          let(:first_result) do
            Cuprum::Result.new(value: first_value, errors: first_errors)
          end

          include_examples 'should call the block'

          describe 'with on: :always' do
            let(:conditional) { :always }

            include_examples 'should call the block'
          end

          describe 'with on: :failure' do
            let(:conditional) { :failure }

            include_examples 'should call the block'
          end

          describe 'with on: :success' do
            let(:conditional) { :success }

            include_examples 'should not call the block'
          end
        end

        context 'when multiple results are tapped' do
          let(:results) do
            %w[second third fourth].
              map { |str| "#{str} value" }.
              map { |str| Cuprum::Result.new(value: str) }
          end
          let(:chained) do
            instance.
              send(:tap_result!) do |result|
                yielded << result
                results[0]
              end.
              send(:tap_result!) do |result|
                yielded << result
                results[1]
              end.
              send(:tap_result!) do |result|
                yielded << result
                results[2]
              end
          end
          let(:yielded) { [] }

          it 'should yield the first result to each block' do
            chained.call

            expect(yielded).to be == Array.new(3) { first_result }
          end

          it 'should return the first result' do
            expect(chained.call.to_cuprum_result).to be first_result
          end
        end
      end

      describe '#yield_result' do
        shared_examples 'should call the block' do
          it 'should yield the previous result to the block' do
            expect do |block|
              instance.yield_result(on: conditional, &block).call
            end.
              to yield_with_args(first_result)
          end

          context 'when the block returns a value' do
            it 'should wrap the value in a result' do
              value   = 'final value'
              chained = instance.yield_result(on: conditional) { value }
              result  = chained.call.to_cuprum_result

              expect(result).to be_a Cuprum::Result
              expect(result.value).to be value
            end
          end

          context 'when the block returns an operation' do
            it 'should return the result' do
              result    = Cuprum::Result.new(value: 'final value')
              operation = Cuprum::Operation.new { result }
              chained   =
                instance.yield_result(on: conditional) { operation.call }

              expect(chained.call.to_cuprum_result).to be result
            end
          end

          context 'when the block returns a result' do
            it 'should return the result' do
              result  = Cuprum::Result.new(value: 'final value')
              chained = instance.yield_result(on: conditional) { result }

              expect(chained.call.to_cuprum_result).to be result
            end
          end
        end

        shared_examples 'should not call the block' do
          it 'should not yield to the block' do
            expect do |block|
              instance.yield_result(on: conditional, &block).call
            end.
              not_to yield_control
          end

          it 'should return the previous result' do
            chained = instance.yield_result(on: conditional) {}

            expect(chained.call.to_cuprum_result).to be first_result
          end
        end

        let(:first_value)   { 'first value' }
        let(:first_errors)  { ['first error'] }
        let(:first_result)  { Cuprum::Result.new(value: first_value) }
        let(:chained_block) { ->() {} }
        let(:conditional)   { nil }

        before(:example) do
          allow(instance).to receive(:process).and_return(first_result)
        end

        it 'should define the method' do
          expect(instance).
            to respond_to(:yield_result).
            with(0).arguments.
            and_keywords(:on).
            and_a_block
        end

        it 'should clone the command' do
          chained = instance.yield_result(on: conditional) {}

          expect(chained).to be_a described_class
          expect(chained).not_to be instance
        end

        include_examples 'should call the block'

        describe 'with on: :always' do
          let(:conditional) { :always }

          include_examples 'should call the block'
        end

        describe 'with on: :failure' do
          let(:conditional) { :failure }

          include_examples 'should not call the block'
        end

        describe 'with on: :success' do
          let(:conditional) { :success }

          include_examples 'should call the block'
        end

        context 'when the previous result is failing' do
          let(:first_result) do
            Cuprum::Result.new(value: first_value, errors: first_errors)
          end

          include_examples 'should call the block'

          describe 'with on: :always' do
            let(:conditional) { :always }

            include_examples 'should call the block'
          end

          describe 'with on: :failure' do
            let(:conditional) { :failure }

            include_examples 'should call the block'
          end

          describe 'with on: :success' do
            let(:conditional) { :success }

            include_examples 'should not call the block'
          end
        end

        context 'when multiple results are yielded' do
          let(:results) do
            %w[second third fourth].
              map { |str| "#{str} value" }.
              map { |str| Cuprum::Result.new(value: str) }
          end
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
          end
          let(:yielded) { [] }

          it 'should yield each result to the next block' do
            chained.call

            expect(yielded).to be == [first_result, results[0], results[1]]
          end

          it 'should return the final result' do
            expect(chained.call.to_cuprum_result).to be results.last
          end
        end
      end

      describe '#yield_result!' do
        shared_examples 'should call the block' do
          it 'should yield the previous result to the block' do
            expect do |block|
              instance.send(:yield_result!, on: conditional, &block).call
            end.
              to yield_with_args(first_result)
          end

          context 'when the block returns a value' do
            it 'should wrap the value in a result' do
              value   = 'final value'
              chained =
                instance.send(:yield_result!, on: conditional) { value }
              result  = chained.call.to_cuprum_result

              expect(result).to be_a Cuprum::Result
              expect(result.value).to be value
            end
          end

          context 'when the block returns an operation' do
            it 'should return the result' do
              result    = Cuprum::Result.new(value: 'final value')
              operation = Cuprum::Operation.new { result }
              chained   =
                instance.send(:yield_result!, on: conditional) do
                  operation.call
                end

              expect(chained.call.to_cuprum_result).to be result
            end
          end

          context 'when the block returns a result' do
            it 'should return the result' do
              result  = Cuprum::Result.new(value: 'final value')
              chained =
                instance.send(:yield_result!, on: conditional) { result }

              expect(chained.call.to_cuprum_result).to be result
            end
          end
        end

        shared_examples 'should not call the block' do
          it 'should not yield to the block' do
            expect do |block|
              instance.yield_result(on: conditional, &block).call
            end.
              not_to yield_control
          end

          it 'should return the previous result' do
            chained = instance.yield_result(on: conditional) {}

            expect(chained.call.to_cuprum_result).to be first_result
          end
        end

        let(:first_value)   { 'first value' }
        let(:first_errors)  { ['first error'] }
        let(:first_result)  { Cuprum::Result.new(value: first_value) }
        let(:chained_block) { ->() {} }
        let(:conditional)   { nil }

        before(:example) do
          allow(instance).to receive(:process).and_return(first_result)
        end

        it 'should define the method' do
          expect(instance).
            to respond_to(:yield_result!, true).
            with(0).arguments.
            and_keywords(:on).
            and_a_block
        end

        it 'should return the command' do
          chained = instance.send(:yield_result!, on: conditional) {}

          expect(chained).to be instance
        end

        include_examples 'should call the block'

        describe 'with on: :always' do
          let(:conditional) { :always }

          include_examples 'should call the block'
        end

        describe 'with on: :failure' do
          let(:conditional) { :failure }

          include_examples 'should not call the block'
        end

        describe 'with on: :success' do
          let(:conditional) { :success }

          include_examples 'should call the block'
        end

        context 'when the previous result is failing' do
          let(:first_result) do
            Cuprum::Result.new(value: first_value, errors: first_errors)
          end

          include_examples 'should call the block'

          describe 'with on: :always' do
            let(:conditional) { :always }

            include_examples 'should call the block'
          end

          describe 'with on: :failure' do
            let(:conditional) { :failure }

            include_examples 'should call the block'
          end

          describe 'with on: :success' do
            let(:conditional) { :success }

            include_examples 'should not call the block'
          end
        end

        context 'when multiple results are yielded' do
          let(:results) do
            %w[second third fourth].
              map { |str| "#{str} value" }.
              map { |str| Cuprum::Result.new(value: str) }
          end
          let(:chained) do
            instance.
              send(:yield_result!) do |result|
                yielded << result
                results[0]
              end.
              send(:yield_result!) do |result|
                yielded << result
                results[1]
              end.
              send(:yield_result!) do |result|
                yielded << result
                results[2]
              end
          end
          let(:yielded) { [] }

          it 'should yield each result to the next block' do
            chained.call

            expect(yielded).to be == [first_result, results[0], results[1]]
          end

          it 'should return the final result' do
            expect(chained.call.to_cuprum_result).to be results.last
          end
        end
      end
    end
  end
end
