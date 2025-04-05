# frozen_string_literal: true

require 'cuprum/parameter_validation'
require 'cuprum/rspec/be_a_result'

RSpec.describe Cuprum::ParameterValidation do
  include Cuprum::RSpec::Matchers

  subject(:command) { described_class.new }

  deferred_context 'when the command class defines validations' do
    let(:command_validations) do
      [
        described_class::ValidationRule.new(
          name: :author,
          type: :name,
          as:   'author'
        ),
        described_class::ValidationRule.new(
          name:     :quantity,
          type:     :instance_of,
          as:       'amount',
          expected: Integer
        )
      ]
    end

    before(:example) do
      Spec::ValidatedCommand.validate(:author, :name)
      Spec::ValidatedCommand
        .validate(:quantity, :instance_of, as: 'amount', expected: Integer)
    end
  end

  deferred_context 'when the parent class defines validations' do
    let(:message) { 'author is not a real doctor' }
    let(:block)   { ->(value) { value&.include?('Doctor') } }
    let(:parent_validations) do
      [
        described_class::ValidationRule.new(
          name:    :author,
          type:    described_class::ValidationRule::BLOCK_VALIDATION_TYPE,
          as:      'author',
          message:,
          &block
        )
      ]
    end

    before(:example) do
      Spec::ParentCommand.validate(:author, message:, &block)
    end
  end

  let(:described_class) { Spec::ValidatedCommand }

  example_class 'Spec::ParentCommand', Cuprum::Command do |klass|
    klass.include Cuprum::ParameterValidation # rubocop:disable RSpec/DescribedClass
  end

  example_class 'Spec::ValidatedCommand', 'Spec::ParentCommand' do |klass|
    klass.define_method(:process) { |author = nil, quantity: nil| :ok } # rubocop:disable Lint/UnusedBlockArgument
  end

  describe '.each_validation' do
    include_examples 'should define class reader', :each_validation

    it { expect(described_class.each_validation).to be_a Enumerator }

    it { expect(described_class.each_validation.to_a).to be == [] }

    describe 'with a block' do
      it 'should not yield control' do
        expect { |block| described_class.each_validation(&block) }
          .not_to yield_control
      end
    end

    wrap_deferred 'when the command class defines validations' do
      let(:expected_validations) { command_validations }

      it 'should return the validations' do
        expect(described_class.each_validation.to_a)
          .to be == expected_validations
      end

      describe 'with a block' do
        it 'should yield the validations' do
          expect { |block| described_class.each_validation(&block) }
            .to yield_successive_args(*expected_validations)
        end
      end
    end

    wrap_deferred 'when the parent class defines validations' do
      let(:expected_validations) { parent_validations }

      it 'should return the validations' do
        expect(described_class.each_validation.to_a)
          .to be == expected_validations
      end

      describe 'with a block' do
        it 'should yield the validations' do
          expect { |block| described_class.each_validation(&block) }
            .to yield_successive_args(*expected_validations)
        end
      end
    end

    context 'when the parent class and command class define validations' do
      let(:expected_validations) { parent_validations + command_validations }

      include_deferred 'when the command class defines validations'
      include_deferred 'when the parent class defines validations'

      it 'should return the validations' do
        expect(described_class.each_validation.to_a)
          .to be == expected_validations
      end

      describe 'with a block' do
        it 'should yield the validations' do
          expect { |block| described_class.each_validation(&block) }
            .to yield_successive_args(*expected_validations)
        end
      end
    end
  end

  describe '.validate' do
    deferred_examples 'should add the validation' do
      let(:validation) { described_class.each_validation.to_a.last }
      let?(:expected_type) do
        type.to_sym
      end
      let?(:expected_options) do
        { as: name.to_s }
      end
      let?(:expected_method_name) do
        case expected_type
        when described_class::ValidationRule::BLOCK_VALIDATION_TYPE
          :validate
        when described_class::ValidationRule::NAMED_VALIDATION_TYPE
          :"validate_#{name}"
        else
          :"validate_#{expected_type}"
        end
      end

      it 'should add the validation rule' do
        expect { define_validation }.to(
          change { described_class.each_validation.count }.by(1)
        )
      end

      it 'should configure the validation rule', :aggregate_failures do
        define_validation

        expect(validation.name).to be name.to_sym
        expect(validation.type).to be expected_type
        expect(validation.method_name).to be expected_method_name
        expect(validation.options).to be == expected_options
        expect(validation.block).to be == block
      end

      describe 'with options' do
        let(:options)          { super().merge(as: 'author_name') }
        let(:expected_options) { super().merge(options.except(:using)) }

        it 'should configure the validation rule', :aggregate_failures do
          define_validation

          expect(validation.name).to be name.to_sym
          expect(validation.type).to be expected_type
          expect(validation.options).to be == expected_options
          expect(validation.block).to be == block
        end
      end
    end

    let(:name)    { 'author' }
    let(:type)    { :name }
    let(:options) { {} }
    let(:block)   { nil }

    def define_validation
      described_class.validate(name, type, **options, &block)
    end

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:validate)
        .with(1..2).arguments
        .and_any_keywords
        .and_a_block
    end

    describe 'with name: nil' do
      let(:error_message) { "name can't be blank" }

      it 'should raise an exception' do
        expect { described_class.validate(nil) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with name: an Object' do
      let(:name)          { Object.new.freeze }
      let(:error_message) { 'name is not a String or a Symbol' }

      it 'should raise an exception' do
        expect { described_class.validate(name) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with name: an empty String' do
      let(:error_message) { "name can't be blank" }

      it 'should raise an exception' do
        expect { described_class.validate('') }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with name: an empty Symbol' do
      let(:error_message) { "name can't be blank" }

      it 'should raise an exception' do
        expect { described_class.validate(:'') }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with type: an Object' do
      let(:type)          { Object.new.freeze }
      let(:error_message) { 'type is not a String or a Symbol' }

      it 'should raise an exception' do
        expect { described_class.validate(name, type) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with type: an empty String' do
      let(:error_message) { "type can't be blank" }

      it 'should raise an exception' do
        expect { described_class.validate(name, '') }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with type: an empty Symbol' do
      let(:error_message) { "type can't be blank" }

      it 'should raise an exception' do
        expect { described_class.validate(name, :'') }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with using: an empty String' do
      let(:error_message) { "using can't be blank" }

      it 'should raise an exception' do
        expect { described_class.validate(name, using: '') }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with using: an empty Symbol' do
      let(:error_message) { "using can't be blank" }

      it 'should raise an exception' do
        expect { described_class.validate(name, using: :'') }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with name: a String' do
      let(:name) { 'author' }
      let(:type) { nil }
      let(:expected_type) do
        described_class::ValidationRule::NAMED_VALIDATION_TYPE
      end

      include_deferred 'should add the validation'
    end

    describe 'with name: a Symbol' do
      let(:name) { :author }
      let(:type) { nil }
      let(:expected_type) do
        described_class::ValidationRule::NAMED_VALIDATION_TYPE
      end

      include_deferred 'should add the validation'
    end

    describe 'with name: value and a block' do
      let(:type)  { nil }
      let(:block) { ->(_) {} }
      let(:expected_type) do
        described_class::ValidationRule::BLOCK_VALIDATION_TYPE
      end

      include_deferred 'should add the validation'
    end

    describe 'with name: value and type: a Class' do
      let(:type)             { String }
      let(:expected_type)    { :instance_of }
      let(:expected_options) { { expected: String, as: 'author' } }

      include_deferred 'should add the validation'
    end

    describe 'with name: value and type: a String' do
      let(:type) { 'name' }

      include_deferred 'should add the validation'
    end

    describe 'with name: value and type: a Symbol' do
      let(:type) { :name }

      include_deferred 'should add the validation'
    end

    describe 'with name: value and using_method: a String' do
      let(:type)    { nil }
      let(:options) { super().merge(using: 'is_a_palindrome') }
      let(:expected_type) do
        described_class::ValidationRule::NAMED_VALIDATION_TYPE
      end
      let(:expected_method_name) do
        :is_a_palindrome
      end

      include_deferred 'should add the validation'
    end

    describe 'with name: value and using_method: a Symbol' do
      let(:type)    { nil }
      let(:options) { super().merge(using: :is_a_palindrome) }
      let(:expected_type) do
        described_class::ValidationRule::NAMED_VALIDATION_TYPE
      end
      let(:expected_method_name) do
        :is_a_palindrome
      end

      include_deferred 'should add the validation'
    end
  end

  describe '#call' do
    let(:arguments) { [] }
    let(:keywords)  { {} }
    let(:block)     { -> {} }

    def call_command
      command.call(*arguments, **keywords, &block)
    end

    it 'should define the method' do
      expect(command)
        .to respond_to(:call)
        .with_unlimited_arguments
        .and_any_keywords
        .and_a_block
    end

    it { expect(call_command).to be_a_passing_result.with_value(:ok) }

    wrap_deferred 'when the parent class defines validations' do
      describe 'with non-matching parameters' do
        let(:arguments) { ['Mister Skelebone'] }
        let(:expected_error) do
          failures = ['author is not a real doctor']

          Cuprum::Errors::InvalidParameters
            .new(command_class: described_class, failures:)
        end

        it 'should return a failing result with an InvalidParameters error' do
          expect(call_command)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with matching parameters' do
        let(:arguments) { ['Doctor Skelebone'] }

        it { expect(call_command).to be_a_passing_result.with_value(:ok) }
      end
    end

    wrap_deferred 'when the command class defines validations' do
      describe 'with non-matching parameters' do
        let(:expected_error) do
          failures = [
            "author can't be blank",
            'amount is not an instance of Integer'
          ]

          Cuprum::Errors::InvalidParameters
            .new(command_class: described_class, failures:)
        end

        it 'should return a failing result with an InvalidParameters error' do
          expect(call_command)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with partially-matching parameters' do
        let(:arguments) { ['Doctor Skelebone'] }
        let(:expected_error) do
          failures = ['amount is not an instance of Integer']

          Cuprum::Errors::InvalidParameters
            .new(command_class: described_class, failures:)
        end

        it 'should return a failing result with an InvalidParameters error' do
          expect(call_command)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with matching parameters' do
        let(:arguments) { ['Doctor Skelebone'] }
        let(:keywords)  { { quantity: 10_000 } }

        it { expect(call_command).to be_a_passing_result.with_value(:ok) }
      end
    end

    context 'when the parent class and command class define validations' do
      include_deferred 'when the command class defines validations'
      include_deferred 'when the parent class defines validations'

      describe 'with non-matching parameters' do
        let(:expected_error) do
          failures = [
            'author is not a real doctor',
            "author can't be blank",
            'amount is not an instance of Integer'
          ]

          Cuprum::Errors::InvalidParameters
            .new(command_class: described_class, failures:)
        end

        it 'should return a failing result with an InvalidParameters error' do
          expect(call_command)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with partially-matching parameters' do
        let(:arguments) { ['Mister Skelebone'] }
        let(:expected_error) do
          failures = [
            'author is not a real doctor',
            'amount is not an instance of Integer'
          ]

          Cuprum::Errors::InvalidParameters
            .new(command_class: described_class, failures:)
        end

        it 'should return a failing result with an InvalidParameters error' do
          expect(call_command)
            .to be_a_failing_result
            .with_error(expected_error)
        end
      end

      describe 'with matching parameters' do
        let(:arguments) { ['Doctor Skelebone'] }
        let(:keywords)  { { quantity: 10_000 } }

        it { expect(call_command).to be_a_passing_result.with_value(:ok) }
      end
    end

    context 'when the command does not define a #process method' do
      let(:expected_error) do
        Cuprum::Errors::CommandNotImplemented.new(command:)
      end

      before(:example) { described_class.undef_method(:process) }

      it 'should return a failing result with a CommandNotImplemented error' do
        expect(call_command)
          .to be_a_failing_result
          .with_error(expected_error)
      end
    end
  end
end
