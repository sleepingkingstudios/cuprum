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

  subject(:instance) { described_class.new }

  let(:implementation) { ->() {} }
  let(:expected_class) { described_class }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

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
    let(:implementation) { ->() {} }

    context 'when the operation is initialized with a block' do
      shared_context 'when the implementation is defined' do
        subject(:instance) { described_class.new(&implementation) }
      end # shared_context

      include_examples 'should execute the command implementation'

      wrap_context 'when the implementation is defined' do
        context 'when the implementation throws :cuprum_failed_step'

        let(:result) { Cuprum::Result.new(status: :failure) }
        let(:implementation) do
          thrown = result

          ->() { throw :cuprum_failed_step, thrown }
        end

        it 'should return the operation' do
          expect(instance.call).to be instance
        end

        it 'should set the operation result to the thrown result' do
          expect(instance.call.result).to be result
        end
      end
    end # context

    context 'when the #process method is defined' do
      shared_context 'when the implementation is defined' do
        let(:described_class) do
          process = implementation

          Class.new(super()) do |klass|
            klass.send(:define_method, :process, &process)
          end # class
        end # let
      end # shared_context

      include_examples 'should execute the command implementation'

      wrap_context 'when the implementation is defined' do
        context 'when the implementation throws :cuprum_failed_step'

        let(:result) { Cuprum::Result.new(status: :failure) }
        let(:implementation) do
          thrown = result

          ->() { throw :cuprum_failed_step, thrown }
        end

        it 'should return the operation' do
          expect(instance.call).to be instance
        end

        it 'should set the operation result to the thrown result' do
          expect(instance.call.result).to be result
        end
      end
    end # context
  end # describe
end # describe
