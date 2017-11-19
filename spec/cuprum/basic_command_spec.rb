require 'cuprum/basic_command'

require 'support/examples/command_examples'

RSpec.describe Cuprum::BasicCommand do
  include Spec::Examples::CommandExamples

  subject(:instance) { described_class.new }

  let(:implementation) { ->() {} }
  let(:result_class)   { Cuprum::Result }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  include_examples 'should implement the Command methods'

  include_examples 'should implement the Command methods for any implementation'
end # describe
