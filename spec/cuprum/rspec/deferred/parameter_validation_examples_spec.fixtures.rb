# frozen_string_literal: true

require 'rspec/sleeping_king_studios/concerns/example_constants'

require 'cuprum/parameter_validation'
require 'cuprum/rspec/deferred/parameter_validation_examples'

RSpec.describe Cuprum::RSpec::Deferred::ParameterValidationExamples do
  include Cuprum::RSpec::Deferred::ParameterValidationExamples # rubocop:disable RSpec/DescribedClass
  extend  RSpec::SleepingKingStudios::Concerns::ExampleConstants
  include RSpec::SleepingKingStudios::Deferred::Consumer

  subject(:command) { described_class.new }

  let(:described_class) { Spec::ValidatedCommand }
  let(:name)            { 'Self-Sealing Stem Bolt' }
  let(:quantity)        { 1_000 }

  example_class 'Spec::ValidatedCommand', Cuprum::Command do |klass|
    klass.include Cuprum::ParameterValidation

    klass.define_method(:process) do |name = nil, quantity = nil|
      { name:, quantity: }
    end

    klass.validate :name,     :presence, as: 'item name'
    klass.validate :quantity, Integer
  end

  def call_command
    command.call(name, quantity)
  end

  describe '"should validate the parameter" examples' do
    describe 'with message: value' do
      context 'when the parameters are valid' do
        include_deferred 'should validate the parameter',
          :quantity,
          message: 'quantity is invalid'
      end

      context 'when the parameters are invalid with non-matching errors' do
        let(:quantity) { nil }

        include_deferred 'should validate the parameter',
          :quantity,
          message: 'quantity is invalid'
      end

      context 'when the parameters are invalid with matching error' do
        let(:quantity) { nil }

        include_deferred 'should validate the parameter',
          :quantity,
          message: 'quantity is not an instance of Integer'
      end
    end

    describe 'with type: value' do
      context 'when the parameters are valid' do
        include_deferred 'should validate the parameter',
          :name,
          'sleeping_king_studios.tools.assertions.presence',
          as: 'item name'
      end

      context 'when the parameters are invalid with non-matching errors' do
        let(:quantity) { nil }

        include_deferred 'should validate the parameter',
          :name,
          'sleeping_king_studios.tools.assertions.presence',
          as: 'item name'
      end

      context 'when the parameters are invalid with matching error' do
        let(:name) { nil }

        include_deferred 'should validate the parameter',
          :name,
          'sleeping_king_studios.tools.assertions.presence',
          as: 'item name'
      end
    end
  end
end
