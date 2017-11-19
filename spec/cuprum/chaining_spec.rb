require 'cuprum/basic_command'
require 'cuprum/chaining'

require 'support/examples/chaining_examples'
require 'support/examples/command_examples'

RSpec.describe Cuprum::Chaining do
  include Spec::Examples::ChainingExamples
  include Spec::Examples::CommandExamples

  subject(:instance) { Spec::CommandWithChaining.new {} }

  let(:result_class) { Cuprum::Result }

  options = { :base_class => Cuprum::BasicCommand }
  example_class 'Spec::CommandWithChaining', options do |klass|
    klass.include described_class
  end # klass

  include_examples 'should implement the Command methods'

  include_examples 'should implement the Command chaining methods'
end # describe
