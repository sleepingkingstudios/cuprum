require 'cuprum/function_examples'
require 'cuprum/operation_examples'
require 'cuprum/operations/null_operation'

RSpec.describe Cuprum::Operations::NullOperation do
  include Spec::Examples::FunctionExamples
  include Spec::Examples::OperationExamples

  subject(:instance) { described_class.new }

  include_examples 'should implement the Function methods'

  include_examples 'should implement the Operation methods'

  describe '#call' do
    it { expect(instance).to respond_to(:call).with(0).arguments }

    it { expect(instance.call).to be instance }
  end # describe

  describe '#errors' do
    it { expect(instance.errors).to be nil }

    it { expect(instance.call.errors).to be_empty }
  end # describe

  describe '#failure?' do
    it { expect(instance.failure?).to be false }

    it { expect(instance.call.failure?).to be false }
  end # describe

  describe '#halted?' do
    it { expect(instance.halted?).to be false }

    it { expect(instance.call.halted?).to be false }
  end # describe

  describe '#success?' do
    it { expect(instance.success?).to be false }

    it { expect(instance.call.success?).to be true }
  end # describe

  describe '#value' do
    it { expect(instance.value).to be nil }

    it { expect(instance.call.value).to be nil }
  end # describe
end # describe
