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
          expect(instance)
            .to respond_to(:step)
            .with(0..1).arguments
            .and_unlimited_arguments
            .and_any_keywords
            .and_a_block
        end
      end

      describe '#steps' do
        it { expect(instance).to respond_to(:steps).with(0).arguments }
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
          let(:error_message) { 'expected a block or a method name' }

          it 'should raise an exception' do
            expect { instance.step }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with no arguments and a block' do
          let(:block) { -> { returned_value } }

          def call_step
            instance.step(&block)
          end

          it 'should call the block' do
            expect { |block| instance.step(&block) }.to yield_control
          end

          include_examples 'should wrap the returned value'
        end

        describe 'with nil' do
          let(:error_message) { 'expected a block or a method name' }

          it 'should raise an exception' do
            expect { instance.step(nil) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with an object' do
          let(:error_message) do
            'expected method name to be a String or Symbol'
          end

          it 'should raise an exception' do
            expect { instance.step(Object.new.freeze) }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with an empty method name' do
          let(:error_message) { "method name can't be blank" }

          it 'should raise an exception' do
            expect { instance.step('') }
              .to raise_error ArgumentError, error_message
          end
        end

        describe 'with a method name' do
          let(:method_name) { :custom_method }

          def call_step
            instance.step(method_name)
          end

          before(:example) do
            instance.singleton_class.send(:define_method, method_name) {}

            allow(instance).to receive(method_name).and_return(returned_value)
          end

          it 'should call the method' do
            instance.step(method_name)

            expect(instance).to have_received(method_name).with(no_args)
          end

          include_examples 'should wrap the returned value'
        end

        describe 'with a method name and arguments' do
          let(:method_name) { 'custom_method' }
          let(:method_args) { %w[ichi ni san] }

          before(:example) do
            instance.singleton_class.send(:define_method, method_name) { |*_| }

            allow(instance).to receive(method_name).and_return(returned_value)
          end

          def call_step
            instance.step(method_name, *method_args)
          end

          it 'should call the method' do
            instance.step(method_name, *method_args)

            expect(instance).to have_received(method_name).with(*method_args)
          end

          include_examples 'should wrap the returned value'
        end

        describe 'with a method name and keywords' do
          let(:method_name)   { 'custom_method' }
          let(:method_kwargs) { { uno: 1, dos: 2, tres: 3 } }

          before(:example) do
            instance.singleton_class.send(:define_method, method_name) { |**_| }

            allow(instance).to receive(method_name).and_return(returned_value)
          end

          def call_step
            instance.step(method_name, **method_kwargs)
          end

          it 'should call the method' do
            instance.step(method_name, **method_kwargs)

            expect(instance).to have_received(method_name).with(**method_kwargs)
          end

          include_examples 'should wrap the returned value'
        end

        describe 'with a method name and a block' do
          let(:method_name)  { 'custom_method' }
          let(:method_block) { -> {} }

          before(:example) do
            instance.singleton_class.send(:define_method, method_name) {}

            allow(instance).to receive(method_name) do |&block|
              block.call

              returned_value
            end
          end

          def call_step
            instance.step(method_name, &method_block)
          end

          it 'should call the method' do
            instance.step(method_name, &method_block)

            expect(instance).to have_received(method_name).with(no_args)
          end

          it 'should yield the block' do
            expect { |block| instance.step(method_name, &block) }
              .to yield_control
          end

          include_examples 'should wrap the returned value'
        end

        describe 'with a method name, arguments, keywords, and a block' do
          let(:method_name)   { 'custom_method' }
          let(:method_args)   { %w[ichi ni san] }
          let(:method_kwargs) { { uno: 1, dos: 2, tres: 3 } }
          let(:method_block)  { -> {} }

          before(:example) do
            instance.singleton_class.send(:define_method, method_name) \
            { |*_, **_, &block| }

            allow(instance).to receive(method_name) do |*_, **_, &block|
              block.call

              returned_value
            end
          end

          def call_step(&block)
            instance.step(
              method_name,
              *method_args,
              **method_kwargs,
              &(block || method_block)
            )
          end

          it 'should call the method' do
            call_step

            expect(instance)
              .to have_received(method_name)
              .with(*method_args, **method_kwargs)
          end

          it 'should yield the block' do
            expect { |block| call_step(&block) }
              .to yield_control
          end

          include_examples 'should wrap the returned value'
        end
      end

      describe '#steps' do
        describe 'without a block' do
          let(:error_message) { 'no block given (yield)' }

          it 'should raise an exception' do
            expect { instance.steps }
              .to raise_error LocalJumpError, error_message
          end
        end

        describe 'with an empty block' do
          it 'should return a passing result' do
            expect(instance.steps {}).to be_a_passing_result.with_value(nil)
          end
        end

        describe 'with a block that returns an object' do
          let(:returned_value) { Object.new.freeze }

          it 'should return a passing result' do
            expect(instance.steps { returned_value })
              .to be_a_passing_result
              .with_value(returned_value)
          end
        end

        describe 'with a block that returns a failing result' do
          let(:returned_result) { Cuprum::Result.new(status: :failure) }

          it 'should return the result' do
            expect(instance.steps { returned_result }).to be returned_result
          end
        end

        describe 'with a block that returns a passing result' do
          let(:returned_result) { Cuprum::Result.new(status: :success) }

          it 'should return the result' do
            expect(instance.steps { returned_result }).to be returned_result
          end
        end

        describe 'with a block that raises an exception' do
          let(:error_message) { 'something went wrong' }

          it 'should raise the exception' do
            expect { instance.steps { raise error_message } }
              .to raise_error StandardError, error_message
          end
        end

        describe 'with a block that throws a symbol' do
          let(:thrown_symbol) { :something_went_wrong }
          let(:thrown_value)  { Object.new.freeze }

          it 'should throw the symbol' do
            expect { instance.steps { throw thrown_symbol, thrown_value } }
              .to throw_symbol(thrown_symbol, thrown_value)
          end
        end

        describe 'with a block that throws :cuprum_failed_step' do
          let(:thrown_symbol) { :cuprum_failed_step }
          let(:thrown_result) { Cuprum::Result.new(status: :failure) }

          it 'should return the failing result' do
            expect(instance.steps { throw thrown_symbol, thrown_result })
              .to be thrown_result
          end
        end
      end
    end
  end
end
