# frozen_string_literal: true

require 'cuprum/processing'

require 'support/examples/processing_examples'

RSpec.describe Cuprum::Processing do
  include Spec::Examples::ProcessingExamples

  subject(:instance) { described_class.new }

  let(:described_class) { Class.new { include Cuprum::Processing } }

  include_examples 'should implement the Processing interface'

  include_examples 'should implement the Processing methods'

  describe '#call' do
    shared_context 'when the implementation is defined' do
      let(:described_class) do
        super().tap do |klass|
          klass.send(:define_method, :process, &implementation)
        end
      end
    end

    let(:implementation) { ->() {} }

    include_examples 'should execute the command implementation'
  end
end
