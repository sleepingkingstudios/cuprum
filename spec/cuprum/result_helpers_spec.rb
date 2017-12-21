require 'cuprum/processing'
require 'cuprum/result_helpers'

require 'support/examples/result_helpers_examples'

RSpec.describe Cuprum::ResultHelpers do
  include Spec::Examples::ResultHelpersExamples

  subject(:instance) { described_class.new }

  let(:described_class) do
    Class.new do
      include Cuprum::Processing
      include Cuprum::ResultHelpers

      def process *_args; end
    end # class
  end # let

  include_examples 'should implement the ResultHelpers methods'

  describe '#errors' do
    include_examples 'should have private reader', :errors
  end # describe
end # describe
