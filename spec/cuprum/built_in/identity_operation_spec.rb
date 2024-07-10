# frozen_string_literal: true

require 'cuprum/built_in/identity_operation'

require 'support/examples/operation_examples'
require 'support/examples/processing_examples'

RSpec.describe Cuprum::BuiltIn::IdentityOperation do
  include Spec::Examples::OperationExamples
  include Spec::Examples::ProcessingExamples

  subject(:operation) { described_class.new }

  let(:command) { operation }
  let(:value)   { 'returned value' }
  let(:error)   { Cuprum::Error.new(message: 'Something went wrong.') }
  let(:result)  { Cuprum::Result.new(value:, error:) }

  include_examples 'should implement the Operation methods'

  include_examples 'should implement the Processing interface'

  describe '#call' do
    it { expect(operation).to respond_to(:call).with(0..1).arguments }

    it { expect(operation.call).to be operation }
  end

  describe '#error' do
    it { expect(operation.error).to be nil }

    it { expect(operation.call.error).to be nil }

    it { expect(operation.call(value).error).to be nil }

    it { expect(operation.call(result).error).to be == error }
  end

  describe '#failure?' do
    it { expect(operation.failure?).to be false }

    it { expect(operation.call.failure?).to be false }

    it { expect(operation.call(value).failure?).to be false }

    it { expect(operation.call(result).failure?).to be true }
  end

  describe '#success?' do
    it { expect(operation.success?).to be false }

    it { expect(operation.call.success?).to be true }

    it { expect(operation.call(value).success?).to be true }

    it { expect(operation.call(result).success?).to be false }
  end

  describe '#value' do
    it { expect(operation.value).to be nil }

    it { expect(operation.call.value).to be nil }

    it { expect(operation.call(value).value).to be == value }

    it { expect(operation.call(result).value).to be == value }
  end
end
