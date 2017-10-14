require 'cuprum/built_in/null_operation'
require 'cuprum/function_examples'
require 'cuprum/operation_examples'

RSpec.describe Cuprum::BuiltIn::NullOperation do
  include Spec::Examples::FunctionExamples
  include Spec::Examples::OperationExamples

  subject(:instance) { described_class.new }

  include_examples 'should implement the Function methods'

  include_examples 'should implement the Operation methods'

  describe '#call' do
    it { expect(instance).to respond_to(:call).with(0).arguments }

    it { expect(instance.call).to be instance }

    describe 'with arbitrary arguments' do
      it { expect(instance.call(1, 2, :san => 'san') { :yon }).to be instance }
    end # describe
  end # describe

  describe '#errors' do
    it { expect(instance.errors).to be nil }

    it { expect(instance.call.errors).to be_empty }

    describe 'with arbitrary arguments' do
      it 'should not set any errors' do
        expect(instance.call(1, 2, :san => 'san') { :yon }.errors).to be_empty
      end # it
    end # describe
  end # describe

  describe '#failure?' do
    it { expect(instance.failure?).to be false }

    it { expect(instance.call.failure?).to be false }

    describe 'with arbitrary arguments' do
      it 'should not set the status to failure' do
        expect(instance.call(1, 2, :san => 'san') { :yon }.failure?).to be false
      end # it
    end # describe
  end # describe

  describe '#halted?' do
    it { expect(instance.halted?).to be false }

    it { expect(instance.call.halted?).to be false }

    describe 'with arbitrary arguments' do
      it 'should not be halt the operation' do
        expect(instance.call(1, 2, :san => 'san') { :yon }.halted?).to be false
      end # it
    end # describe
  end # describe

  describe '#success?' do
    it { expect(instance.success?).to be false }

    it { expect(instance.call.success?).to be true }

    describe 'with arbitrary arguments' do
      it 'should set the status to success' do
        expect(instance.call(1, 2, :san => 'san') { :yon }.success?).to be true
      end # it
    end # describe
  end # describe

  describe '#value' do
    it { expect(instance.value).to be nil }

    it { expect(instance.call.value).to be nil }

    describe 'with arbitrary arguments' do
      it 'should set the value to nil' do
        expect(instance.call(1, 2, :san => 'san') { :yon }.value).to be nil
      end # it
    end # describe
  end # describe
end # describe
