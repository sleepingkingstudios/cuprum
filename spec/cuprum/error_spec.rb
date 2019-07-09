# frozen_string_literal: true

require 'cuprum/error'

RSpec.describe Cuprum::Error do
  subject(:error) { described_class.new(message: message) }

  let(:message) { nil }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:message)
    end
  end

  describe '#message' do
    include_examples 'should have reader', :message, nil

    context 'when initialized with no arguments' do
      subject(:error) { described_class.new }

      it { expect(error.message).to be nil }
    end

    context 'when initialized with a message' do
      let(:message) { 'Something went wrong.' }

      it { expect(error.message).to be == message }
    end
  end
end
