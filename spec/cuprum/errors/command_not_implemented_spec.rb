# frozen_string_literal: true

require 'cuprum/errors/command_not_implemented'

RSpec.describe Cuprum::Errors::CommandNotImplemented do
  subject(:error) { described_class.new(command: command) }

  let(:command) { Spec::ExampleCommand.new }

  example_class 'Spec::ExampleCommand', Cuprum::Command

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:command)
    end

    describe 'with no arguments' do
      let(:error_message) { 'missing keyword: command' }

      it 'should raise an error' do
        expect { described_class.new }
          .to raise_error ArgumentError, error_message
      end
    end
  end

  describe '#command' do
    include_examples 'should have reader', :command, -> { command }
  end

  describe '#message' do
    let(:expected_message) do
      'no implementation defined for Spec::ExampleCommand'
    end

    include_examples 'should have reader',
      :message,
      -> { be == expected_message }

    context 'when initialized with a nil command' do
      let(:command) { nil }
      let(:expected_message) do
        'no implementation defined for command'
      end

      it { expect(error.message).to be == expected_message }
    end
  end
end
