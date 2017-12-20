require 'cuprum/chaining'
require 'cuprum/processing'

require 'support/examples/chaining_examples'
require 'support/examples/command_examples'

RSpec.describe Cuprum::Chaining do
  include Spec::Examples::ChainingExamples
  include Spec::Examples::CommandExamples

  subject(:instance) { Spec::CommandWithChaining.new {} }

  let(:result_class) { Cuprum::Result }

  example_class 'Spec::CommandWithChaining' do |klass|
    klass.include Cuprum::Processing
    klass.include described_class
  end # klass

  include_examples 'should implement the Command methods'

  include_examples 'should implement the Command chaining methods'
end # describe
