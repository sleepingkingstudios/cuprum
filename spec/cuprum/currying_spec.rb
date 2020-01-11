# frozen_string_literal: true

require 'cuprum/currying'

require 'support/examples/currying_examples'

RSpec.describe Cuprum::Currying do
  include Spec::Examples::CurryingExamples

  subject(:instance) { described_class.new }

  let(:described_class) { Class.new { include Cuprum::Currying } }

  include_examples 'should implement the Currying interface'

  include_examples 'should implement the Currying methods'
end
