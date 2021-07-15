# frozen_string_literal: true

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

require 'cuprum/error'

module Spec::Examples
  module CurryingExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_examples 'should implement the Currying interface' do
      describe '#curry' do
        it 'should define the method' do
          expect(subject)
            .to respond_to(:curry)
            .with_unlimited_arguments
            .and_any_keywords
        end
      end
    end

    shared_examples 'should implement the Currying methods' do
      describe '#curry' do
        shared_examples 'should curry the command' do
          let(:curried_command) do
            subject.curry(*arguments, **keywords, &block)
          end

          it 'should return a curried command' do
            expect(curried_command).to be_a Cuprum::Currying::CurriedCommand
          end

          it 'should set the arguments' do
            expect(curried_command.arguments).to be == arguments
          end

          it 'should set the block' do
            expect(curried_command.block).to be block
          end

          it 'should set the command' do
            expect(curried_command.command).to be subject
          end

          it 'should set the keywords' do
            expect(curried_command.keywords).to be == keywords
          end
        end

        let(:arguments) { [] }
        let(:block)     { nil }
        let(:keywords)  { {} }

        describe 'with no arguments or keywords' do
          it 'should return the command' do
            expect(subject.curry).to be subject
          end
        end

        describe 'with one argument' do
          let(:arguments) { %w[foo] }

          include_examples 'should curry the command'
        end

        describe 'with many arguments' do
          let(:arguments) { %w[foo bar baz] }

          include_examples 'should curry the command'
        end

        describe 'with one keyword' do
          let(:keywords) { { ichi: 1 } }

          include_examples 'should curry the command'
        end

        describe 'with many keywords' do
          let(:keywords) { { ichi: 1, ni: 2, san: 3 } }

          include_examples 'should curry the command'
        end

        describe 'with a block' do
          let(:block) { -> {} }

          include_examples 'should curry the command'
        end

        describe 'with many arguments and keywords' do
          let(:arguments) { %w[foo bar baz] }
          let(:keywords)  { { ichi: 1, ni: 2, san: 3 } }

          include_examples 'should curry the command'
        end

        describe 'with many arguments, keywords, and a block' do
          let(:arguments) { %w[foo bar baz] }
          let(:keywords)  { { ichi: 1, ni: 2, san: 3 } }
          let(:block)     { -> {} }

          include_examples 'should curry the command'
        end
      end
    end
  end
end
