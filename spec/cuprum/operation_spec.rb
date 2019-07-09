require 'cuprum/operation'

require 'support/examples/chaining_examples'
require 'support/examples/operation_examples'
require 'support/examples/processing_examples'

RSpec.describe Cuprum::Operation do
  include Spec::Examples::ChainingExamples
  include Spec::Examples::OperationExamples
  include Spec::Examples::ProcessingExamples

  subject(:instance) { described_class.new }

  let(:implementation) { ->() {} }
  let(:expected_class) { described_class }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  include_examples 'should implement the Chaining methods'

  include_examples 'should implement the Operation methods'

  include_examples 'should implement the Processing interface'

  include_examples 'should implement the Processing methods'

  describe '#call' do
    let(:implementation) { ->() {} }

    context 'when the operation is initialized with a block' do
      shared_context 'when the implementation is defined' do
        subject(:instance) { described_class.new(&implementation) }
      end # shared_context

      include_examples 'should execute the command implementation'
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
    end # context
  end # describe
end # describe
