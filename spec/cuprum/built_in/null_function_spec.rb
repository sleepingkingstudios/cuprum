require 'cuprum/built_in/null_function'

require 'support/examples/command_examples'

RSpec.describe Cuprum::BuiltIn::NullFunction do
  include Spec::Examples::CommandExamples

  subject(:instance) { described_class.new }

  include_examples 'should implement the Command methods'

  describe '#call' do
    it { expect(instance).to respond_to(:call).with(0).arguments }

    it 'should return a result', :aggregate_failures do
      result = instance.call

      expect(result).to be_a Cuprum::Result
      expect(result.value).to be nil
      expect(result.errors).to be_empty
      expect(result.success?).to be true
      expect(result.failure?).to be false
      expect(result.halted?).to be false
    end # it

    describe 'with arbitrary arguments' do
      it 'should return a result', :aggregate_failures do
        result = instance.call(1, 2, :san => 'san') { :yon }

        expect(result).to be_a Cuprum::Result
        expect(result.value).to be nil
        expect(result.errors).to be_empty
        expect(result.success?).to be true
        expect(result.failure?).to be false
        expect(result.halted?).to be false
      end # it
    end # describe
  end # describe
end # describe
