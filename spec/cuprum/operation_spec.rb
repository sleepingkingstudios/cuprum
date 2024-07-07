# frozen_string_literal: true

require 'cuprum/operation'

require 'support/examples/currying_examples'
require 'support/examples/operation_examples'
require 'support/examples/processing_examples'
require 'support/examples/result_helpers_examples'
require 'support/examples/steps_examples'

RSpec.describe Cuprum::Operation do
  include Spec::Examples::CurryingExamples
  include Spec::Examples::OperationExamples
  include Spec::Examples::ProcessingExamples
  include Spec::Examples::ResultHelpersExamples
  include Spec::Examples::StepsExamples

  subject(:operation) { described_class.new }

  let(:command)        { operation }
  let(:implementation) { -> {} }
  let(:expected_class) { described_class }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end

  include_examples 'should implement the Currying interface'

  include_examples 'should implement the Currying methods'

  include_examples 'should implement the Operation methods'

  include_examples 'should implement the Processing interface'

  include_examples 'should implement the Processing methods'

  include_examples 'should implement the ResultHelpers interface'

  include_examples 'should implement the ResultHelpers methods'

  include_examples 'should implement the Steps interface'

  include_examples 'should implement the Steps methods'

  describe '#call' do
    let(:implementation) { -> {} }

    context 'when the operation is initialized with a block' do
      shared_context 'when the implementation is defined' do
        subject(:command) { described_class.new(&implementation) }
      end

      include_examples 'should execute the command implementation'

      wrap_context 'when the implementation is defined' do
        context 'when the implementation throws :cuprum_failed_step'

        let(:result) { Cuprum::Result.new(status: :failure) }
        let(:implementation) do
          thrown = result

          -> { throw :cuprum_failed_step, thrown }
        end

        it 'should return the operation' do
          expect(command.call).to be command
        end

        it 'should set the operation result to the thrown result' do
          expect(command.call.result).to be result
        end
      end
    end

    context 'when the #process method is defined' do
      shared_context 'when the implementation is defined' do
        let(:described_class) do
          process = implementation

          Class.new(super()) do |klass|
            klass.send(:define_method, :process, &process)
          end
        end
      end

      include_examples 'should execute the command implementation'

      wrap_context 'when the implementation is defined' do
        context 'when the implementation throws :cuprum_failed_step'

        let(:result) { Cuprum::Result.new(status: :failure) }
        let(:implementation) do
          thrown = result

          -> { throw :cuprum_failed_step, thrown }
        end

        it 'should return the operation' do
          expect(command.call).to be command
        end

        it 'should set the operation result to the thrown result' do
          expect(command.call.result).to be result
        end
      end
    end
  end

  describe '#to_proc' do
    let(:proc)   { operation.to_proc }
    let(:result) { proc.call }
    let(:expected_error) do
      Cuprum::Errors::CommandNotImplemented.new(command: operation)
    end

    it { expect(operation).to respond_to(:to_proc).with(0).arguments }

    it { expect(operation.to_proc).to be_a Proc }

    it { expect(operation.to_proc).to be proc }

    it { expect(result).to be operation }

    it { expect(result.success?).to be false }

    it { expect(result.error).to be == expected_error }

    it { expect(nil.then(&operation)).to be operation }

    it 'should call the operation with arguments' do
      # rubocop:disable RSpec/SubjectStub
      arguments = %w[ichi ni san]

      allow(operation).to receive(:call)

      proc.call(*arguments)

      expect(operation).to have_received(:call).with(*arguments)
      # rubocop:enable RSpec/SubjectStub
    end

    it 'should call the operation with keywords' do
      # rubocop:disable RSpec/SubjectStub
      keywords = { ichi: 1, ni: 2, san: 3 }

      allow(operation).to receive(:call)

      proc.call(**keywords)

      expect(operation).to have_received(:call).with(**keywords)
      # rubocop:enable RSpec/SubjectStub
    end

    context 'when the implementation is defined' do
      let(:described_class) do
        process = implementation

        Class.new(super()) do |klass|
          klass.send(:define_method, :process, &process)
        end
      end
      let(:implementation) { lambda(&:upcase) }
      let(:value)          { 'Greetings, programs!' }
      let(:result)         { proc.call(value) }
      let(:expected_value) { value.upcase }

      it { expect(result).to be operation }

      it { expect(result.success?).to be true }

      it { expect(result.value).to be == expected_value }

      it { expect(value.then(&operation).value).to be == expected_value }
    end
  end
end
