# frozen_string_literal: true

require 'cuprum/parameter_validation/validator'
require 'cuprum/rspec/be_a_result'

RSpec.describe Cuprum::ParameterValidation::Validator do
  include Cuprum::RSpec::Matchers

  subject(:validator) { described_class.new }

  describe '::UnknownValidationError' do
    include_examples 'should define constant',
      :UnknownValidationError,
      -> { be_a(Class).and(be < StandardError) }
  end

  describe '#call' do
    let(:command)    { Spec::CustomCommand.new }
    let(:parameters) { {} }
    let(:rules)      { [] }

    example_class 'Spec::CustomCommand', Cuprum::Command

    def call_validator
      validator.call(command:, parameters:, rules:)
    end

    it 'should define the method' do
      expect(validator)
        .to respond_to(:call)
        .with(0).arguments
        .and_keywords(:command, :parameters, :rules)
    end

    it { expect(call_validator).to be_a_passing_result }

    describe 'with a basic validation rule' do
      let(:rules) do
        [
          Cuprum::ParameterValidation::ValidationRule
            .new(name: :author, type: :name)
        ]
      end

      describe 'with empty parameters' do
        let(:expected_error) do
          Cuprum::Errors::InvalidParameters.new(
            command_class: Spec::CustomCommand,
            failures:      ["author can't be blank"]
          )
        end

        it 'should return a failing result with invalid parameters error' do
          expect(call_validator)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with non-matching parameters' do
        let(:parameters) { { author: Object.new } }
        let(:expected_error) do
          Cuprum::Errors::InvalidParameters.new(
            command_class: Spec::CustomCommand,
            failures:      ['author is not a String or a Symbol']
          )
        end

        it 'should return a failing result with invalid parameters error' do
          expect(call_validator)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with matching parameters' do
        let(:parameters) { { author: 'Doctor Skelebone' } }

        it { expect(call_validator).to be_a_passing_result }
      end

      describe 'with as: value' do
        let(:rules) do
          [
            Cuprum::ParameterValidation::ValidationRule
              .new(name: :author, type: :name, as: 'author name')
          ]
        end

        describe 'with non-matching parameters' do
          let(:parameters) { { author: Object.new } }
          let(:expected_error) do
            Cuprum::Errors::InvalidParameters.new(
              command_class: Spec::CustomCommand,
              failures:      ['author name is not a String or a Symbol']
            )
          end

          it 'should return a failing result with invalid parameters error' do
            expect(call_validator)
              .to be_a_failing_result
              .with_error(expected_error)
          end
        end
      end

      describe 'with options' do
        let(:rules) do
          [
            Cuprum::ParameterValidation::ValidationRule
              .new(name: :author, type: :instance_of, expected: String)
          ]
        end

        describe 'with non-matching parameters' do
          let(:parameters) { { author: Object.new } }
          let(:expected_error) do
            Cuprum::Errors::InvalidParameters.new(
              command_class: Spec::CustomCommand,
              failures:      ['author is not an instance of String']
            )
          end

          it 'should return a failing result with invalid parameters error' do
            expect(call_validator)
              .to be_a_failing_result
              .with_error(expected_error)
          end
        end
      end

      context 'when the receiver defines the validation method' do
        before(:example) do
          Spec::CustomCommand.class_eval do
            private

            def validate_name(value, as:, **)
              return if value.include?('Doctor')

              "#{as} is not a real doctor"
            end
          end
        end

        describe 'with non-matching parameters' do
          let(:parameters) { { author: 'Mister Skelebone' } }
          let(:expected_error) do
            Cuprum::Errors::InvalidParameters.new(
              command_class: Spec::CustomCommand,
              failures:      ['author is not a real doctor']
            )
          end

          it 'should return a failing result with invalid parameters error' do
            expect(call_validator)
              .to be_a_failing_result
              .with_error(expected_error)
          end
        end

        describe 'with matching parameters' do
          let(:parameters) { { author: 'Doctor Skelebone' } }

          it { expect(call_validator).to be_a_passing_result }
        end
      end
    end

    describe 'with a block validation rule' do
      let(:rules) do
        type =
          Cuprum::ParameterValidation::ValidationRule::BLOCK_VALIDATION_TYPE

        [
          Cuprum::ParameterValidation::ValidationRule
            .new(name: :quantity, type:) { |value| value.is_a?(Integer) }
        ]
      end

      describe 'with empty parameters' do
        let(:expected_error) do
          Cuprum::Errors::InvalidParameters.new(
            command_class: Spec::CustomCommand,
            failures:      ['quantity is invalid']
          )
        end

        it 'should return a failing result with invalid parameters error' do
          expect(call_validator)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with non-matching parameters' do
        let(:parameters) { { quantity: Object.new } }
        let(:expected_error) do
          Cuprum::Errors::InvalidParameters.new(
            command_class: Spec::CustomCommand,
            failures:      ['quantity is invalid']
          )
        end

        it 'should return a failing result with invalid parameters error' do
          expect(call_validator)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with matching parameters' do
        let(:parameters) { { quantity: 10_000 } }

        it { expect(call_validator).to be_a_passing_result }
      end

      describe 'with as: value' do
        let(:rules) do
          type =
            Cuprum::ParameterValidation::ValidationRule::BLOCK_VALIDATION_TYPE

          [
            Cuprum::ParameterValidation::ValidationRule
              .new(as: 'item quantity', name: :quantity, type:) do |value|
                value.is_a?(Integer)
              end
          ]
        end
        let(:expected_error) do
          Cuprum::Errors::InvalidParameters.new(
            command_class: Spec::CustomCommand,
            failures:      ['item quantity is invalid']
          )
        end

        it 'should return a failing result with invalid parameters error' do
          expect(call_validator)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with message: value' do
        let(:rules) do
          message = 'quantity must be an Integer'
          type =
            Cuprum::ParameterValidation::ValidationRule::BLOCK_VALIDATION_TYPE

          [
            Cuprum::ParameterValidation::ValidationRule
              .new(message:, name: :quantity, type:) do |value|
                value.is_a?(Integer)
              end
          ]
        end
        let(:expected_error) do
          Cuprum::Errors::InvalidParameters.new(
            command_class: Spec::CustomCommand,
            failures:      ['quantity must be an Integer']
          )
        end

        it 'should return a failing result with invalid parameters error' do
          expect(call_validator)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end
    end

    describe 'with a named validation rule' do
      let(:rules) do
        type =
          Cuprum::ParameterValidation::ValidationRule::NAMED_VALIDATION_TYPE

        [
          Cuprum::ParameterValidation::ValidationRule.new(name: :author, type:)
        ]
      end
      let(:error_message) do
        "undefined method 'validate_author' for an instance of " \
          'Spec::CustomCommand'
      end

      it 'should raise an exception' do
        expect { call_validator }
          .to raise_error described_class::UnknownValidationError, error_message
      end

      context 'when the receiver defines the validation method' do
        before(:example) do
          Spec::CustomCommand.class_eval do
            private

            def validate_author(value, as:, **)
              return if value.include?('Doctor')

              "#{as} is not a real doctor"
            end
          end
        end

        describe 'with non-matching parameters' do
          let(:parameters) { { author: 'Mister Skelebone' } }
          let(:expected_error) do
            Cuprum::Errors::InvalidParameters.new(
              command_class: Spec::CustomCommand,
              failures:      ['author is not a real doctor']
            )
          end

          it 'should return a failing result with invalid parameters error' do
            expect(call_validator)
              .to be_a_failing_result
              .with_error(expected_error)
          end
        end

        describe 'with matching parameters' do
          let(:parameters) { { author: 'Doctor Skelebone' } }

          it { expect(call_validator).to be_a_passing_result }
        end
      end
    end

    describe 'with multiple validation rules' do
      let(:rules) do
        [
          Cuprum::ParameterValidation::ValidationRule
            .new(name: :author, type: :presence),
          Cuprum::ParameterValidation::ValidationRule
            .new(name: :author, type: :instance_of, expected: String),
          Cuprum::ParameterValidation::ValidationRule
            .new(name: :quantity, type: :instance_of, expected: Integer)
        ]
      end

      describe 'with empty parameters' do
        let(:expected_error) do
          Cuprum::Errors::InvalidParameters.new(
            command_class: Spec::CustomCommand,
            failures:      [
              "author can't be blank",
              'author is not an instance of String',
              'quantity is not an instance of Integer'
            ]
          )
        end

        it 'should return a failing result with invalid parameters error' do
          expect(call_validator)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with non-matching parameters' do
        let(:parameters) do
          {
            author:   :'',
            quantity: Object.new.freeze
          }
        end
        let(:expected_error) do
          Cuprum::Errors::InvalidParameters.new(
            command_class: Spec::CustomCommand,
            failures:      [
              "author can't be blank",
              'author is not an instance of String',
              'quantity is not an instance of Integer'
            ]
          )
        end

        it 'should return a failing result with invalid parameters error' do
          expect(call_validator)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with partially-matching parameters' do
        let(:parameters) do
          {
            author:   'Doctor Skelebone',
            quantity: Object.new.freeze
          }
        end
        let(:expected_error) do
          Cuprum::Errors::InvalidParameters.new(
            command_class: Spec::CustomCommand,
            failures:      ['quantity is not an instance of Integer']
          )
        end

        it 'should return a failing result with invalid parameters error' do
          expect(call_validator)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with matching parameters' do
        let(:parameters) do
          {
            author:   'Doctor Skelebone',
            quantity: 10_000
          }
        end

        it { expect(call_validator).to be_a_passing_result }
      end
    end

    describe 'with a rule with unknown type' do
      let(:rules) do
        [
          Cuprum::ParameterValidation::ValidationRule
            .new(name: :article, type: :random)
        ]
      end
      let(:error_message) do
        'unknown validation type :random'
      end

      it 'should raise an exception' do
        expect { call_validator }
          .to raise_error described_class::UnknownValidationError, error_message
      end
    end
  end
end
