# frozen_string_literal: true

require 'cuprum/errors/invalid_parameters'

RSpec.describe Cuprum::Errors::InvalidParameters do
  subject(:error) { described_class.new(**constructor_options) }

  let(:command_class) { Spec::CustomCommand }
  let(:failures)      { ["name can't be blank", 'quantity must be an Integer'] }
  let(:constructor_options) do
    { command_class:, failures: }
  end

  example_class 'Spec::CustomCommand', Cuprum::Command

  describe '::TYPE' do
    include_examples 'should define immutable constant',
      :TYPE,
      'cuprum.errors.invalid_parameters'
  end

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:command_class, :failures)
    end
  end

  describe '#as_json' do
    let(:expected) do
      {
        'data'    => {
          'command_class' => command_class.name,
          'failures'      => failures
        },
        'message' => error.message,
        'type'    => error.type
      }
    end

    include_examples 'should have reader', :as_json, -> { be == expected }
  end

  describe '#command_class' do
    include_examples 'should define reader',
      :command_class,
      -> { command_class }
  end

  describe '#failures' do
    include_examples 'should define reader', :failures, -> { failures }
  end

  describe '#message' do
    let(:expected_message) do
      "invalid parameters for #{command_class.name} - #{failures.join(', ')}"
    end

    include_examples 'should define reader', :message, -> { expected_message }
  end

  describe '#type' do
    include_examples 'should define reader', :type, -> { described_class::TYPE }
  end
end
