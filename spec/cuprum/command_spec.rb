require 'cuprum/command'

require 'support/examples/chaining_examples'
require 'support/examples/command_examples'
require 'support/examples/result_helpers_examples'

RSpec.describe Cuprum::Command do
  include Spec::Examples::ChainingExamples
  include Spec::Examples::CommandExamples
  include Spec::Examples::ResultHelpersExamples

  subject(:instance) { described_class.new }

  let(:implementation) { ->() {} }
  let(:result_class)   { Cuprum::Result }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  include_examples 'should implement the Command methods'

  include_examples 'should implement the Command methods for any implementation'

  include_examples 'should implement the Command chaining methods'

  include_examples 'should implement the ResultHelpers methods'

  describe '#errors' do
    include_examples 'should have private reader', :errors
  end # describe
end # describe
