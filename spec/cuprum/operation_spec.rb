require 'cuprum/operation'

require 'support/examples/command_examples'
require 'support/examples/operation_examples'
require 'support/examples/result_helpers_examples'

RSpec.describe Cuprum::Operation do
  include Spec::Examples::CommandExamples
  include Spec::Examples::OperationExamples
  include Spec::Examples::ResultHelpersExamples

  subject(:instance) { described_class.new }

  let(:implementation) { ->() {} }
  let(:result_class)   { described_class }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  include_examples 'should implement the Command methods'

  include_examples 'should implement the Command methods for any implementation'

  include_examples 'should implement the Operation methods'

  include_examples 'should implement the ResultHelpers methods'
end # describe
