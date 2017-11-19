require 'cuprum/built_in/identity_operation'
require 'cuprum/function_examples'
require 'cuprum/operation_examples'

require 'support/examples/command_examples'

RSpec.describe Cuprum::BuiltIn::IdentityOperation do
  include Spec::Examples::CommandExamples
  include Spec::Examples::FunctionExamples
  include Spec::Examples::OperationExamples

  subject(:instance) { described_class.new }

  let(:value)  { 'returned value'.freeze }
  let(:errors) { ['errors.messages.unknown'] }
  let(:result) { Cuprum::Result.new(value, :errors => errors) }

  include_examples 'should implement the Command methods'

  include_examples 'should implement the Function methods'

  include_examples 'should implement the Operation methods'

  describe '#call' do
    it { expect(instance).to respond_to(:call).with(0..1).arguments }

    it { expect(instance.call).to be instance }
  end # describe

  describe '#errors' do
    it { expect(instance.errors).to be nil }

    it { expect(instance.call.errors).to be_empty }

    it { expect(instance.call(value).errors).to be_empty }

    it { expect(instance.call(result).errors).to be == errors }
  end # describe

  describe '#failure?' do
    it { expect(instance.failure?).to be false }

    it { expect(instance.call.failure?).to be false }

    it { expect(instance.call(value).failure?).to be false }

    it { expect(instance.call(result).failure?).to be true }
  end # describe

  describe '#halted?' do
    it { expect(instance.halted?).to be false }

    it { expect(instance.call.halted?).to be false }

    it { expect(instance.call(value).halted?).to be false }

    it { expect(instance.call(result).halted?).to be false }

    it { expect(instance.call(result.halt!).halted?).to be true }
  end # describe

  describe '#success?' do
    it { expect(instance.success?).to be false }

    it { expect(instance.call.success?).to be true }

    it { expect(instance.call(value).success?).to be true }

    it { expect(instance.call(result).success?).to be false }
  end # describe

  describe '#value' do
    it { expect(instance.value).to be nil }

    it { expect(instance.call.value).to be nil }

    it { expect(instance.call(value).value).to be == value }

    it { expect(instance.call(result).value).to be == value }
  end # describe
end # describe
