# frozen_string_literal: true

require 'cuprum/result_helpers'

require 'support/examples/result_helpers_examples'

RSpec.describe Cuprum::ResultHelpers do
  include Spec::Examples::ResultHelpersExamples

  subject(:instance) { described_class.new }

  let(:described_class) { Class.new { include Cuprum::ResultHelpers } }

  include_examples 'should implement the ResultHelpers interface'

  include_examples 'should implement the ResultHelpers methods'
end
