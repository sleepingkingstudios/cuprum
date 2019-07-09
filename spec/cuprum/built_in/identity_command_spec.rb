require 'cuprum/built_in/identity_command'

require 'support/examples/processing_examples'

RSpec.describe Cuprum::BuiltIn::IdentityCommand do
  include Spec::Examples::ProcessingExamples

  subject(:instance) { described_class.new }

  include_examples 'should implement the Processing interface'

  describe '#call' do
    it { expect(instance).to respond_to(:call).with(0..1).arguments }

    describe 'with nil' do
      it 'should return a result', :aggregate_failures do
        result = instance.call

        expect(result).to be_a Cuprum::Result
        expect(result.value).to be nil
        expect(result.error).to be nil
        expect(result.success?).to be true
        expect(result.failure?).to be false
      end # it
    end # describe

    describe 'with a value' do
      let(:value) { 'expected value'.freeze }

      it 'should return a result', :aggregate_failures do
        result = instance.call(value)

        expect(result).to be_a Cuprum::Result
        expect(result.value).to be value
        expect(result.error).to be nil
        expect(result.success?).to be true
        expect(result.failure?).to be false
      end # it
    end # describe

    describe 'with a result' do
      let(:value)    { 'expected value'.freeze }
      let(:error)    { Cuprum::Error.new(message: 'Something went wrong.') }
      let(:expected) { Cuprum::Result.new(value: value, error: error) }

      it 'should return the result', :aggregate_failures do
        result = instance.call(expected)

        expect(result).to be_a Cuprum::Result
        expect(result.value).to be value
        expect(result.error).to be == error
        expect(result.success?).to be false
        expect(result.failure?).to be true
      end # it
    end # describe
  end # describe
end # describe
