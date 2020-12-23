# frozen_string_literal: true

require 'cuprum/built_in/null_operation'

require 'support/examples/operation_examples'
require 'support/examples/processing_examples'

RSpec.describe Cuprum::BuiltIn::NullOperation do
  include Spec::Examples::OperationExamples
  include Spec::Examples::ProcessingExamples

  subject(:operation) { described_class.new }

  let(:command) { operation }

  include_examples 'should implement the Operation methods'

  include_examples 'should implement the Processing interface'

  describe '#call' do
    it { expect(operation).to respond_to(:call).with(0).arguments }

    it { expect(operation.call).to be operation }

    describe 'with arbitrary arguments' do
      it { expect(operation.call(1, 2, san: 'san') { :yon }).to be operation }
    end
  end

  describe '#error' do
    it { expect(operation.error).to be nil }

    it { expect(operation.call.error).to be nil }

    describe 'with arbitrary arguments' do
      it 'should not set any errors' do
        expect(operation.call(1, 2, san: 'san') { :yon }.error).to be nil
      end
    end
  end

  describe '#failure?' do
    it { expect(operation.failure?).to be false }

    it { expect(operation.call.failure?).to be false }

    describe 'with arbitrary arguments' do
      it 'should not set the status to failure' do
        expect(operation.call(1, 2, san: 'san') { :yon }.failure?).to be false
      end
    end
  end

  describe '#success?' do
    it { expect(operation.success?).to be false }

    it { expect(operation.call.success?).to be true }

    describe 'with arbitrary arguments' do
      it 'should set the status to success' do
        expect(operation.call(1, 2, san: 'san') { :yon }.success?).to be true
      end
    end
  end

  describe '#value' do
    it { expect(operation.value).to be nil }

    it { expect(operation.call.value).to be nil }

    describe 'with arbitrary arguments' do
      it 'should set the value to nil' do
        expect(operation.call(1, 2, san: 'san') { :yon }.value).to be nil
      end
    end
  end
end
