# frozen_string_literal: true

require 'cuprum/built_in/identity_command'

require 'support/examples/processing_examples'

RSpec.describe Cuprum::BuiltIn::IdentityCommand do
  include Spec::Examples::ProcessingExamples

  subject(:command) { described_class.new }

  include_examples 'should implement the Processing interface'

  describe '#call' do
    it { expect(command).to respond_to(:call).with(0..1).arguments }

    describe 'with nil' do
      it 'should return a result', :aggregate_failures do
        result = command.call

        expect(result).to be_a Cuprum::Result
        expect(result.value).to be nil
        expect(result.error).to be nil
        expect(result.success?).to be true
        expect(result.failure?).to be false
      end
    end

    describe 'with a value' do
      let(:value) { 'expected value' }

      it 'should return a result', :aggregate_failures do
        result = command.call(value)

        expect(result).to be_a Cuprum::Result
        expect(result.value).to be value
        expect(result.error).to be nil
        expect(result.success?).to be true
        expect(result.failure?).to be false
      end
    end

    describe 'with a result' do
      let(:value)    { 'expected value' }
      let(:error)    { Cuprum::Error.new(message: 'Something went wrong.') }
      let(:expected) { Cuprum::Result.new(value:, error:) }

      it 'should return the result', :aggregate_failures do
        result = command.call(expected)

        expect(result).to be_a Cuprum::Result
        expect(result.value).to be value
        expect(result.error).to be == error
        expect(result.success?).to be false
        expect(result.failure?).to be true
      end
    end
  end
end
