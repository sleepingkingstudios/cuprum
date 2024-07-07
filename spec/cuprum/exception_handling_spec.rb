# frozen_string_literal: true

require 'cuprum/command'
require 'cuprum/exception_handling'
require 'cuprum/rspec/be_a_result'

RSpec.describe Cuprum::ExceptionHandling do
  include Cuprum::RSpec::Matchers

  subject(:command) { Spec::ExampleCommand.new(param) }

  let(:param) { nil }

  example_class 'Spec::ExampleCommand', Cuprum::Command do |klass|
    klass.include Cuprum::ExceptionHandling # rubocop:disable RSpec/DescribedClass

    klass.define_method(:initialize) do |param|
      @param = param
    end

    klass.attr_reader :param

    klass.define_method(:process) do
      raise param if param.is_a?(Exception)

      return failure(param) if param.is_a?(Cuprum::Error)

      success(param)
    end
  end

  describe '#call' do
    context 'when the command returns a failing result' do
      let(:param) { Cuprum::Error.new(message: 'Something went wrong.') }

      it { expect(command.call).to be_a_failing_result.with_error(param) }
    end

    context 'when the command returns a passing result' do
      let(:param) { :ok }

      it { expect(command.call).to be_a_passing_result.with_value(param) }
    end

    context 'when the command raises a standard error' do
      let(:error_message) { 'Something went wrong.' }
      let(:param)         { StandardError.new(error_message) }
      let(:expected_message) do
        'uncaught exception in Spec::ExampleCommand - '
      end
      let(:expected_error) do
        Cuprum::Errors::UncaughtException
          .new(exception: param, message: expected_message)
      end

      it { expect { command.call }.not_to raise_error }

      it 'should return a failing result' do
        expect(command.call).to be_a_failing_result.with_error(expected_error)
      end

      context 'when the ENV["CUPRUM_RERAISE_EXCEPTIONS"] flag is set' do
        wrap_env 'CUPRUM_RERAISE_EXCEPTIONS', 'true'

        it 'should raise the exception' do
          expect { command.call }.to raise_error StandardError, error_message
        end
      end
    end

    context 'when the command raises an exception' do
      let(:error_message) { 'Something went wrong.' }
      let(:param)         { Exception.new(error_message) }

      it 'should raise the exception' do
        expect { command.call }.to raise_error Exception, error_message
      end
    end
  end
end
