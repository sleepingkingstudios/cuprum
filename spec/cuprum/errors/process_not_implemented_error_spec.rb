require 'cuprum/errors/process_not_implemented_error'

RSpec.describe Cuprum::Errors::ProcessNotImplementedError do
  subject(:instance) { described_class.new(message) }

  let(:message) { nil }

  it { expect(instance).to be_a StandardError }

  describe '::DEFAULT_MESSAGE' do
    let(:expected) { 'no implementation defined for command'.freeze }

    it 'should define the constant' do
      expect(described_class).
        to have_immutable_constant(:DEFAULT_MESSAGE).
        with_value(be == expected)
    end
  end

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0..1).arguments }
  end

  describe '#message' do
    let(:expected) { 'no implementation defined for command'.freeze }

    it { expect(instance.message).to be == expected }

    context 'when the error is initialized with a message' do
      let(:message) do
        'Unable to log out because you are not logged in. Please log in so ' \
        'you can log out.'
      end

      it { expect(instance.message).to be == message }
    end
  end
end
