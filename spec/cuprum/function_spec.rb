# spec/cuprum/function_spec.rb

require 'cuprum/function'

RSpec.describe Cuprum::Function do
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

  subject(:instance) { described_class.new }

  let(:implementation) { ->() {} }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  describe '::NotImplementedError' do
    let(:error_class) { described_class::NotImplementedError }

    it { expect(described_class).to have_constant(:NotImplementedError) }

    it 'should be an error class' do
      expect(error_class).to be_a Class
      expect(error_class).to be < StandardError
    end # it
  end # describe

  describe '#call' do
    shared_examples 'should forward all arguments' do
      context 'when the implementation does not support the given arguments' do
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

          expect(result).to be_a Cuprum::Result
          expect(result.value).to be value
          expect(result.errors).to be_empty
        end # it
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

          expect(result).to be_a Cuprum::Result
          expect(result.value).to be value

          expected_errors.each do |message|
            expect(result.errors).to include message
          end # each
        end # it
      end # context
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
    end # wrap_context

    wrap_context 'when the #process method is defined' do
      it 'should not raise an error' do
        expect { instance.call }.not_to raise_error
      end # it

      include_examples 'should forward all arguments'

      include_examples 'should return a result'
    end # wrap_context
  end # describe
end # describe
