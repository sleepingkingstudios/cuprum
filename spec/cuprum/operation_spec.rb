require 'cuprum/function_examples'
require 'cuprum/operation'
require 'cuprum/operation_examples'

require 'support/examples/command_examples'

RSpec.describe Cuprum::Operation do
  include Spec::Examples::CommandExamples
  include Spec::Examples::FunctionExamples
  include Spec::Examples::OperationExamples

  subject(:instance) { described_class.new }

  let(:implementation) { ->() {} }
  let(:result_class)   { described_class }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  include_examples 'should implement the Command methods'

  include_examples 'should implement the Command methods for any implementation'

  include_examples 'should implement the Function methods'

  include_examples 'should implement the generic Function methods'

  include_examples 'should implement the Operation methods'
end # describe
