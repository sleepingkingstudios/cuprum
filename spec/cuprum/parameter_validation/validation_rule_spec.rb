# frozen_string_literal: true

require 'cuprum/parameter_validation/validation_rule'

RSpec.describe Cuprum::ParameterValidation::ValidationRule do
  subject(:rule) { described_class.new(name:, type:, **options, &block) }

  let(:name)    { :name }
  let(:type)    { :presence }
  let(:options) { {} }
  let(:block)   { nil }

  describe '::BLOCK_VALIDATION_TYPE' do
    include_examples 'should define constant',
      :BLOCK_VALIDATION_TYPE,
      :_block_validation
  end

  describe '::NAMED_VALIDATION_TYPE' do
    include_examples 'should define constant',
      :NAMED_VALIDATION_TYPE,
      :_named_method_validation
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:name, :type)
        .and_any_keywords
        .and_a_block
    end
  end

  describe '#block' do
    include_examples 'should define reader', :block, nil

    context 'when initialized with a block' do
      let(:block) { -> {} }

      it { expect(rule.block).to be block }
    end
  end

  describe '#method_name' do
    include_examples 'should define reader', :method_name, :validate_presence

    context 'when initialized with type: block validation' do
      let(:type) { described_class::BLOCK_VALIDATION_TYPE }

      it { expect(rule.method_name).to be :validate }
    end

    context 'when initialized with type: named method validation' do
      let(:type) { described_class::NAMED_VALIDATION_TYPE }

      it { expect(rule.method_name).to be :validate_name }
    end
  end

  describe '#name' do
    include_examples 'should define reader', :name, -> { name }

    context 'when initialized with name: a String' do
      let(:name) { super().to_s }

      it { expect(rule.name).to be name.to_sym }
    end
  end

  describe '#options' do
    include_examples 'should define reader', :options, {}

    context 'when initialized with options' do
      let(:options) { super().merge(expected: String) }

      it { expect(rule.options).to be == options }
    end
  end

  describe '#type' do
    include_examples 'should define reader', :type, -> { type }

    context 'when initialized type: a String' do
      let(:type) { super().to_s }

      it { expect(rule.type).to be type.to_sym }
    end
  end
end
