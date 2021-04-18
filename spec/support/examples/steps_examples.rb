# frozen_string_literal: true

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

require 'cuprum/error'

require 'cuprum/rspec/be_a_result'

module Spec::Examples
  module StepsExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    shared_examples 'should implement the Steps interface' do
      describe '#step' do
        it 'should define the method' do
          expect(subject)
            .to respond_to(:step)
            .with(0..1).arguments
            .and_unlimited_arguments
            .and_any_keywords
            .and_a_block
        end
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

        before(:example) do
          allow(SleepingKingStudios::Tools::CoreTools)
            .to receive(:deprecate)
            .and_raise
        end

        def wrap_exception
          yield
        rescue StandardError
          # Do nothing.
        end

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

        describe 'with nil' do
          let(:error_message) { 'expected a block or a method name' }

          before(:example) do
            allow(SleepingKingStudios::Tools::CoreTools).to receive(:deprecate)
          end

          it 'should raise an exception' do
            expect { subject.step(nil) }
              .to raise_error ArgumentError, error_message
          end

          it 'should display a deprecation warning' do
            wrap_exception { subject.step(nil) }

            expect(SleepingKingStudios::Tools::CoreTools)
              .to have_received(:deprecate)
          end
        end

        describe 'with an object' do
          let(:error_message) do
            'expected method name to be a String or Symbol'
          end

          before(:example) do
            allow(SleepingKingStudios::Tools::CoreTools).to receive(:deprecate)
          end

          it 'should raise an exception' do
            expect { subject.step(Object.new.freeze) }
              .to raise_error ArgumentError, error_message
          end

          it 'should display a deprecation warning' do
            wrap_exception { subject.step(nil) }

            expect(SleepingKingStudios::Tools::CoreTools)
              .to have_received(:deprecate)
          end
        end

        describe 'with an empty method name' do
          let(:error_message) { "method name can't be blank" }

          before(:example) do
            allow(SleepingKingStudios::Tools::CoreTools).to receive(:deprecate)
          end

          it 'should raise an exception' do
            expect { subject.step('') }
              .to raise_error ArgumentError, error_message
          end

          it 'should display a deprecation warning' do
            wrap_exception { subject.step(nil) }

            expect(SleepingKingStudios::Tools::CoreTools)
              .to have_received(:deprecate)
          end
        end

        describe 'with a method name' do
          let(:method_name) { :custom_method }

          def call_step
            subject.step(method_name)
          end

          before(:example) do
            subject.singleton_class.send(:define_method, method_name) { nil }

            allow(subject).to receive(method_name).and_return(returned_value)

            allow(SleepingKingStudios::Tools::CoreTools).to receive(:deprecate)
          end

          it 'should call the method' do
            subject.step(method_name)

            expect(subject).to have_received(method_name).with(no_args)
          end

          it 'should display a deprecation warning' do
            subject.step(method_name)

            expect(SleepingKingStudios::Tools::CoreTools)
              .to have_received(:deprecate)
          end

          include_examples 'should wrap the returned value'
        end

        describe 'with a method name and arguments' do
          let(:method_name) { 'custom_method' }
          let(:method_args) { %w[ichi ni san] }

          before(:example) do
            # :nocov:
            subject
              .singleton_class
              .send(:define_method, method_name) { |*_| nil }
            # :nocov:

            allow(subject).to receive(method_name).and_return(returned_value)

            allow(SleepingKingStudios::Tools::CoreTools).to receive(:deprecate)
          end

          def call_step
            subject.step(method_name, *method_args)
          end

          it 'should call the method' do
            subject.step(method_name, *method_args)

            expect(subject).to have_received(method_name).with(*method_args)
          end

          it 'should display a deprecation warning' do
            subject.step(method_name, *method_args)

            expect(SleepingKingStudios::Tools::CoreTools)
              .to have_received(:deprecate)
          end

          include_examples 'should wrap the returned value'
        end

        describe 'with a method name and keywords' do
          let(:method_name)   { 'custom_method' }
          let(:method_kwargs) { { uno: 1, dos: 2, tres: 3 } }

          before(:example) do
            # :nocov:
            subject
              .singleton_class
              .send(:define_method, method_name) { |**_| nil }
            # :nocov:

            allow(subject).to receive(method_name).and_return(returned_value)

            allow(SleepingKingStudios::Tools::CoreTools).to receive(:deprecate)
          end

          def call_step
            subject.step(method_name, **method_kwargs)
          end

          it 'should call the method' do
            subject.step(method_name, **method_kwargs)

            expect(subject).to have_received(method_name).with(**method_kwargs)
          end

          it 'should display a deprecation warning' do
            subject.step(method_name, **method_kwargs)

            expect(SleepingKingStudios::Tools::CoreTools)
              .to have_received(:deprecate)
          end

          include_examples 'should wrap the returned value'
        end

        describe 'with a method name and a block' do
          let(:method_name)  { 'custom_method' }
          let(:method_block) { -> {} }

          before(:example) do
            subject.singleton_class.send(:define_method, method_name) { nil }

            allow(subject).to receive(method_name) do |&block|
              block.call

              returned_value
            end

            allow(SleepingKingStudios::Tools::CoreTools).to receive(:deprecate)
          end

          def call_step
            subject.step(method_name, &method_block)
          end

          it 'should call the method' do
            subject.step(method_name, &method_block)

            expect(subject).to have_received(method_name).with(no_args)
          end

          it 'should yield the block' do
            expect { |block| subject.step(method_name, &block) }
              .to yield_control
          end

          it 'should display a deprecation warning' do
            subject.step(method_name, &method_block)

            expect(SleepingKingStudios::Tools::CoreTools)
              .to have_received(:deprecate)
          end

          include_examples 'should wrap the returned value'
        end

        describe 'with a method name, arguments, keywords, and a block' do
          let(:method_name)   { 'custom_method' }
          let(:method_args)   { %w[ichi ni san] }
          let(:method_kwargs) { { uno: 1, dos: 2, tres: 3 } }
          let(:method_block)  { -> {} }

          before(:example) do
            # :nocov:
            subject
              .singleton_class
              .send(:define_method, method_name) { |*_, **_, &_block| nil }
            # :nocov:

            allow(subject).to receive(method_name) do |*_, &block|
              block.call

              returned_value
            end

            allow(SleepingKingStudios::Tools::CoreTools).to receive(:deprecate)
          end

          def call_step(&block)
            subject.step(
              method_name,
              *method_args,
              **method_kwargs,
              &(block || method_block)
            )
          end

          it 'should call the method' do
            call_step

            expect(subject)
              .to have_received(method_name)
              .with(*method_args, **method_kwargs)
          end

          it 'should yield the block' do
            expect { |block| call_step(&block) }
              .to yield_control
          end

          it 'should display a deprecation warning' do
            subject.step(
              method_name,
              *method_args,
              **method_kwargs,
              &method_block
            )

            expect(SleepingKingStudios::Tools::CoreTools)
              .to have_received(:deprecate)
          end

          include_examples 'should wrap the returned value'
        end
      end

      describe '#steps' do
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
