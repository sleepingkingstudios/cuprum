# frozen_string_literal: true

require 'cuprum/parameter_validation'
require 'cuprum/rspec/be_a_result'

RSpec.describe Cuprum::ParameterValidation do
  include Cuprum::RSpec::Matchers

  subject(:command) { described_class.new }

  shared_context 'when the class defines validations' do
    before(:example) do
      Spec::ValidatedCommand.validate :label, :presence
      Spec::ValidatedCommand.validate :quantity, Integer
      Spec::ValidatedCommand.validate :quantity
    end
  end

  let(:described_class) { Spec::ValidatedCommand }

  example_class 'Spec::ValidatedCommand', Cuprum::Command do |klass|
    klass.include Cuprum::ParameterValidation

    klass.define_method(:process) do |label, ok:, quantity: 0, &action|
      ok ? success({ ok: true }) : failure(Cuprum::Error.new(message: 'Something went wrong'))
    end

    klass.define_method(:validate_quantity) do |value, **options|
      return if value.is_a?(Numeric)

      'value must be numeric'
    end
  end

  describe '.validate' do
    pending
  end

  describe '#process' do
    let(:label)    { 'Self-sealing Stem Bolts' }
    let(:quantity) { 1_000 }
    let(:action)   { nil }
    let(:ok)       { true }

    def call_command
      command.call(label, ok:, quantity:, &action)
    end

    pending

    wrap_context 'when the class defines validations' do
      pending

      describe 'with invalid parameters' do
        let(:label)    { nil }
        let(:quantity) { nil }

        it { expect(call_command).to be_a_passing_result }
      end
    end
  end

  pending
end
