# frozen_string_literal: true

require 'cuprum/matching'

require 'support/examples/matching_examples'

RSpec.describe Cuprum::Matching do
  include Spec::Examples::MatchingExamples

  shared_context 'when the matcher has a context' do
    let(:matcher_class) { Spec::MatcherWithContext }
    let(:context)       { Spec::MatcherContext.new }
    let(:matcher)       { described_class.new(context) }
    let(:implementation) do
      ->(message, result = nil) { helper(message, result) }
    end

    example_class 'Spec::MatcherContext' do |klass|
      klass.define_method(:helper) { |message, _result| message.upcase }
    end

    example_class 'Spec::MatcherWithContext' do |klass|
      klass.include Cuprum::Matching # rubocop:disable RSpec/DescribedClass

      klass.define_method(:initialize) { |context| @match_context = context }
    end
  end

  subject(:matcher) { described_class.new }

  let(:matcher_class)   { Spec::Matcher }
  let(:described_class) { matcher_class }

  example_class 'Spec::Matcher' do |klass|
    klass.include Cuprum::Matching # rubocop:disable RSpec/DescribedClass
  end

  describe '::NoMatchError' do
    it { expect(described_class::NoMatchError).to be_a Class }

    it { expect(described_class::NoMatchError).to be < StandardError }
  end

  include_examples 'should implement the Matching interface'

  include_examples 'should implement the Matching methods'
end
