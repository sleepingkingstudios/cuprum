require 'cuprum/function_examples'
require 'cuprum/operation'

RSpec.describe Cuprum::Operation do
  include Spec::Examples::FunctionExamples

  shared_context 'when the implementation generates errors' do
    include_context 'when the function is initialized with a block'

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
  end # shared_context

  shared_context 'when the implementation returns a value' do
    include_context 'when the function is initialized with a block'

    let(:value) { 'returned value'.freeze }
    let(:implementation) do
      returned = value

      ->() { returned }
    end # let
  end # shared_context

  shared_context 'when the implementation halts the function chain' do
    include_context 'when the function is initialized with a block'

    let(:value) { 'returned value'.freeze }
    let(:implementation) do
      returned = value

      lambda do
        halt!

        returned
      end # lambda
    end # let
  end # shared_context

  subject(:instance) { described_class.new }

  let(:implementation) { ->() {} }
  let(:result_class)   { described_class }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  include_examples 'should implement the Function methods'

  include_examples 'should implement the generic Function methods'

  describe '#called?' do
    include_examples 'should have predicate', :called?, false

    wrap_context 'when the implementation returns a value' do
      it 'should return true' do
        instance.call

        expect(instance.called?).to be true
      end # it
    end # wrap_context

    wrap_context 'when the implementation generates errors' do
      it 'should return true' do
        instance.call

        expect(instance.called?).to be true
      end # it
    end # wrap_context
  end # describe

  describe '#errors' do
    include_examples 'should have reader', :errors, nil

    wrap_context 'when the implementation returns a value' do
      it 'should return the errors' do
        instance.call

        expect(instance.errors).to be_empty
      end # it
    end # wrap_context

    wrap_context 'when the implementation generates errors' do
      it 'should return the errors' do
        instance.call

        expected_errors.each do |message|
          expect(instance.errors).to include message
        end # each
      end # it
    end # wrap_context
  end # describe

  describe '#failure?' do
    include_examples 'should have predicate', :failure?, false

    wrap_context 'when the implementation returns a value' do
      it 'should return false' do
        instance.call

        expect(instance.failure?).to be false
      end # it
    end # wrap_context

    wrap_context 'when the implementation generates errors' do
      it 'should return true' do
        instance.call

        expect(instance.failure?).to be true
      end # it
    end # wrap_context
  end # describe

  describe '#halted?' do
    include_examples 'should have predicate', :halted?, false

    wrap_context 'when the implementation halts the function chain' do
      it 'should return true' do
        instance.call

        expect(instance.halted?).to be true
      end # it
    end # method wrap_context
  end # describe

  describe '#reset!' do
    it { expect(instance).to respond_to(:reset!).with(0).arguments }

    wrap_context 'when the function is initialized with a block' do
      it 'should clear the result' do
        instance.call

        expect { instance.reset! }.to change(instance, :called?).to be false
      end # it
    end # wrap_context
  end # describe

  describe '#result' do
    include_examples 'should have reader', :result, nil

    wrap_context 'when the implementation returns a value' do
      it 'should return the last result' do
        instance.call

        result = instance.result
        expect(result).to be_a Cuprum::Result
        expect(result.value).to be value
        expect(result.errors).to be_empty
      end # it
    end # wrap_context

    wrap_context 'when the implementation generates errors' do
      it 'should return the last result' do
        instance.call

        result = instance.result
        expect(result).to be_a Cuprum::Result
        expect(result.value).to be value

        expected_errors.each do |error|
          expect(result.errors).to include error
        end # each
      end # it
    end # wrap_context
  end # describe

  describe '#success?' do
    include_examples 'should have predicate', :success?, false

    wrap_context 'when the implementation returns a value' do
      it 'should return true' do
        instance.call

        expect(instance.success?).to be true
      end # it
    end # wrap_context

    wrap_context 'when the implementation generates errors' do
      it 'should return false' do
        instance.call

        expect(instance.success?).to be false
      end # it
    end # wrap_context
  end # describe

  describe '#value' do
    include_examples 'should have reader', :value, nil

    wrap_context 'when the implementation returns a value' do
      it 'should return the last value' do
        instance.call

        expect(instance.value).to be value
      end # it
    end # wrap_context

    wrap_context 'when the implementation generates errors' do
      it 'should return the last value' do
        instance.call

        expect(instance.value).to be value
      end # it
    end # wrap_context
  end # describe
end # describe
