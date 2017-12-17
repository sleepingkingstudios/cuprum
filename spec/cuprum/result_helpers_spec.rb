require 'cuprum/basic_command'
require 'cuprum/result_helpers'

require 'support/examples/result_helpers_examples'

RSpec.describe Cuprum::ResultHelpers do
  include Spec::Examples::ResultHelpersExamples

  subject(:instance) { described_class.new }

  let(:described_class) do
    Class.new(Cuprum::BasicCommand) do
      include Cuprum::ResultHelpers

      def process *_args; end
    end # class
  end # let

  include_examples 'should implement the ResultHelpers methods'
end # describe
