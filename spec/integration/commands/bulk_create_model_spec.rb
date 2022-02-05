# frozen_string_literal: true

require 'cuprum/rspec/be_a_result'
require 'cuprum/rspec/be_callable'

require 'support/commands/bulk_create_model'
require 'support/models/tag'

# @note Integration spec for Cuprum::MapCommand.
RSpec.describe Spec::Commands::BulkCreateModel do
  include Cuprum::RSpec::Matchers

  subject(:command) { described_class.new(model_class) }

  let(:model_class) { Spec::Models::Tag }

  after(:example) { Spec::Models::Tag.delete_all }

  describe '#call' do
    it { expect(command).to be_callable.with(1).argument }

    describe 'with an empty attributes array' do
      let(:attributes) { [] }

      it 'should return a passing result' do
        expect(command.call(attributes)).to be_a_passing_result.with_value([])
      end
    end

    describe 'with an attributes array with invalid values' do
      let(:attributes) do
        [
          { name: '' },
          { name: 'moist' },
          { name: '' }
        ]
      end
      let(:expected_error) do
        Cuprum::Errors::MultipleErrors.new(
          errors: attributes.map do |hsh|
            Spec::Errors::NotValid.new(
              errors:      model_class
                          .new(attributes: hsh)
                          .tap(&:valid?)
                          .errors,
              model_class: model_class
            )
          end
        )
      end
      let(:expected_value) { Array.new(3) }

      it 'should return a failing result' do
        expect(command.call(attributes))
          .to be_a_failing_result
          .with_error(expected_error)
          .and_value(expected_value)
      end
    end

    describe 'with an attributes array with partially-valid values' do
      let(:attributes) do
        [
          { name: 'valid' },
          { name: 'moist' },
          { name: '' }
        ]
      end
      let(:expected_error) do
        Cuprum::Errors::MultipleErrors.new(
          errors: [
            nil,
            Spec::Errors::NotValid.new(
              errors:      model_class
                          .new(attributes: attributes[1])
                          .tap(&:valid?)
                          .errors,
              model_class: model_class
            ),
            Spec::Errors::NotValid.new(
              errors:      model_class
                          .new(attributes: attributes[2])
                          .tap(&:valid?)
                          .errors,
              model_class: model_class
            )
          ]
        )
      end
      let(:expected_value) do
        [
          model_class.new(attributes: attributes[0]),
          nil,
          nil
        ]
      end

      it 'should return a failing result' do
        expect(command.call(attributes))
          .to be_a_failing_result
          .with_error(expected_error)
          .and_value(expected_value)
      end
    end

    describe 'with an attributes array with valid values' do
      let(:attributes) do
        [
          { name: 'infantry' },
          { name: 'cavalry' },
          { name: 'artillery' }
        ]
      end
      let(:expected_value) do
        attributes.map do |hsh|
          model_class.new(attributes: hsh)
        end
      end

      it 'should return a passing result' do
        expect(command.call(attributes))
          .to be_a_passing_result
          .with_value(expected_value)
          .and_error(nil)
      end
    end
  end

  describe '#model_class' do
    include_examples 'should have reader', :model_class, -> { model_class }
  end
end
