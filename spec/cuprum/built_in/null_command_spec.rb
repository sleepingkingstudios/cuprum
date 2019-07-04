require 'cuprum/built_in/null_command'

require 'support/examples/processing_examples'

RSpec.describe Cuprum::BuiltIn::NullCommand do
  include Spec::Examples::ProcessingExamples

  subject(:instance) { described_class.new }

  include_examples 'should implement the Processing interface'

  describe '#call' do
    it { expect(instance).to respond_to(:call).with(0).arguments }

    it 'should return a result', :aggregate_failures do
      result = instance.call

      expect(result).to be_a Cuprum::Result
      expect(result.value).to be nil
      expect(result.errors).to be nil
      expect(result.success?).to be true
      expect(result.failure?).to be false
    end # it

    describe 'with arbitrary arguments' do
      it 'should return a result', :aggregate_failures do
        result = instance.call(1, 2, :san => 'san') { :yon }

        expect(result).to be_a Cuprum::Result
        expect(result.value).to be nil
        expect(result.errors).to be nil
        expect(result.success?).to be true
        expect(result.failure?).to be false
      end # it
    end # describe
  end # describe
end # describe
