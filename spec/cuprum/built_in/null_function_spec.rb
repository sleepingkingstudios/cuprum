require 'cuprum/built_in/null_function'
require 'cuprum/function_examples'

RSpec.describe Cuprum::BuiltIn::NullFunction do
  include Spec::Examples::FunctionExamples

  subject(:instance) { described_class.new }

  include_examples 'should implement the Function methods'

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
  end # describe
end # describe
