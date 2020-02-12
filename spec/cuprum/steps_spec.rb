# frozen_string_literal: true

require 'cuprum/processing'
require 'cuprum/steps'

require 'support/examples/steps_examples'

RSpec.describe Cuprum::Steps do
  include Spec::Examples::StepsExamples

  subject(:instance) { described_class.new }

  let(:described_class) do
    Class.new do
      include Cuprum::Processing
      include Cuprum::Steps
    end
  end

  include_examples 'should implement the Steps interface'

  include_examples 'should implement the Steps methods'
end
