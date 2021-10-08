# frozen_string_literal: true

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

require 'cuprum/error'

require 'cuprum/rspec/be_a_result'

module Spec::Examples
  module StepsExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_examples 'should implement the Steps interface' do
      describe '#step' do
        it { expect(subject).to respond_to(:step).with(0).arguments }
      end

      describe '#steps' do
        it { expect(subject).to respond_to(:steps).with(0).arguments }
      end
    end

    shared_examples 'should implement the Steps methods' do
      describe '#step' do
        shared_examples 'should wrap the returned value' do
          context 'when the returned value is an object' do
            let(:returned_value) { Object.new.freeze }

            it 'should return the value' do
              expect(call_step).to be returned_value
            end
          end

          context 'when the returned value is a passing result' do
            let(:returned_value) do
              Cuprum::Result.new(value: Object.new.freeze)
            end

            it 'should return the result value' do
              expect(call_step).to be returned_value.value
            end
          end

          context 'when the returned value is a failing result' do
            let(:returned_value) do
              Cuprum::Result.new(status: :failure)
            end

            it 'should throw :cuprum_failed_step and the failing result' do
              expect { call_step }
                .to throw_symbol(:cuprum_failed_step, returned_value)
            end
          end
        end

        let(:returned_value) { Object.new.freeze }

        describe 'with no arguments' do
          let(:error_message) { 'expected a block' }

          it 'should raise an exception' do
            expect { subject.step }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with no arguments and a block' do
          let(:block) { -> { returned_value } }

          def call_step
            subject.step(&block)
          end

          it 'should call the block' do
            expect { |block| subject.step(&block) }.to yield_control
          end

          include_examples 'should wrap the returned value'
        end
      end

      describe '#steps' do
        include Cuprum::RSpec::Matchers

        describe 'without a block' do
          let(:error_message) { 'no block given' }

          it 'should raise an exception' do
            expect { subject.steps }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with an empty block' do
          it 'should return a passing result' do
            expect(subject.steps { nil })
              .to be_a_passing_result.with_value(nil)
          end
        end

        describe 'with a block that returns an object' do
          let(:returned_value) { Object.new.freeze }

          it 'should return a passing result' do
            expect(subject.steps { returned_value })
              .to be_a_passing_result
              .with_value(returned_value)
          end
        end

        describe 'with a block that returns a failing result' do
          let(:returned_result) { Cuprum::Result.new(status: :failure) }

          it 'should return the result' do
            expect(subject.steps { returned_result }).to be returned_result
          end
        end

        describe 'with a block that returns a passing result' do
          let(:returned_result) { Cuprum::Result.new(status: :success) }

          it 'should return the result' do
            expect(subject.steps { returned_result }).to be returned_result
          end
        end

        describe 'with a block that raises an exception' do
          let(:error_message) { 'something went wrong' }

          it 'should raise the exception' do
            expect { subject.steps { raise error_message } }
              .to raise_error StandardError, error_message
          end
        end

        describe 'with a block that throws a symbol' do
          let(:thrown_symbol) { :something_went_wrong }
          let(:thrown_value)  { Object.new.freeze }

          it 'should throw the symbol' do
            expect { subject.steps { throw thrown_symbol, thrown_value } }
              .to throw_symbol(thrown_symbol, thrown_value)
          end
        end

        describe 'with a block that throws :cuprum_failed_step' do
          let(:thrown_symbol) { :cuprum_failed_step }
          let(:thrown_result) { Cuprum::Result.new(status: :failure) }

          it 'should return the failing result' do
            expect(subject.steps { throw thrown_symbol, thrown_result })
              .to be thrown_result
          end
        end
      end
    end
  end
end
