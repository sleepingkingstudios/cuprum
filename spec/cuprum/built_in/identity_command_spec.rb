require 'cuprum/built_in/identity_command'

require 'support/examples/command_examples'

RSpec.describe Cuprum::BuiltIn::IdentityCommand do
  include Spec::Examples::CommandExamples

  subject(:instance) { described_class.new }

  include_examples 'should implement the Command methods'

  describe '#call' do
    it { expect(instance).to respond_to(:call).with(0..1).arguments }

    describe 'with nil' do
      it 'should return a result', :aggregate_failures do
        result = instance.call

        expect(result).to be_a Cuprum::Result
        expect(result.value).to be nil
        expect(result.errors).to be_empty
        expect(result.success?).to be true
        expect(result.failure?).to be false
        expect(result.halted?).to be false
      end # it
    end # describe

    describe 'with a value' do
      let(:value) { 'expected value'.freeze }

      it 'should return a result', :aggregate_failures do
        result = instance.call(value)

        expect(result).to be_a Cuprum::Result
        expect(result.value).to be value
        expect(result.errors).to be_empty
        expect(result.success?).to be true
        expect(result.failure?).to be false
        expect(result.halted?).to be false
      end # it
    end # describe

    describe 'with a result' do
      let(:value)    { 'expected value'.freeze }
      let(:errors)   { ['errors.messages.unknown'] }
      let(:expected) { Cuprum::Result.new(value, :errors => errors) }

      it 'should return the result', :aggregate_failures do
        result = instance.call(expected)

        expect(result).to be_a Cuprum::Result
        expect(result.value).to be value
        expect(result.errors).to be == errors
        expect(result.success?).to be false
        expect(result.failure?).to be true
        expect(result.halted?).to be false
      end # it
    end # describe
  end # describe
end # describe
