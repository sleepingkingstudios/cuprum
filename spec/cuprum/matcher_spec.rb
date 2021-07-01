# frozen_string_literal: true

require 'cuprum/matcher'

require 'support/examples/matching_examples'

RSpec.describe Cuprum::Matcher do
  include Spec::Examples::MatchingExamples

  shared_context 'when the matcher has a context' do
    let(:context) { Spec::MatcherContext.new }
    let(:matcher) { described_class.new(context) }
    let(:implementation) do
      ->(message, result = nil) { helper(message, result) }
    end

    example_class 'Spec::MatcherContext' do |klass|
      klass.define_method(:helper) { |message, _result| message.upcase }
    end
  end

  subject(:matcher) { described_class.new(context, &block) }

  let(:context)         { nil }
  let(:block)           { nil }
  let(:matcher_class)   { Spec::Matcher }
  let(:described_class) { matcher_class }

  example_class 'Spec::Matcher', Cuprum::Matcher # rubocop:disable RSpec/DescribedClass

  include_examples 'should implement the Matching interface'

  include_examples 'should implement the Matching methods'

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to respond_to(:new)
        .with(0..1).arguments
        .and_a_block
    end

    describe 'with a block' do
      let(:block) do
        lambda do
          match(:failure) { 'block failure' }
        end
      end
      let(:result) { Cuprum::Result.new(status: :failure) }

      it 'should add the matches to the matcher' do
        expect(matcher.call(result)).to be == 'block failure'
      end
    end
  end

  describe '#with_context' do
    let(:context) { Spec::MatcherContext.new }
    let(:copy)    { matcher.with_context(context) }

    example_class 'Spec::MatcherContext' do |klass|
      klass.define_method(:helper) { |message, _result| message.upcase }
    end

    it { expect(matcher).to respond_to(:with_context).with(1).argument }

    it 'should alias the method as #using_context' do
      expect(matcher.method(:using_context))
        .to be == matcher.method(:with_context)
    end

    it { expect(copy).to be_a described_class }

    it { expect(copy).not_to be matcher }

    it { expect(copy.match_context).to be context }

    context 'when initialized with a block' do
      let(:block) do
        lambda do
          match(:failure) { 'block failure' }
        end
      end
      let(:result) { Cuprum::Result.new(status: :failure) }

      it 'should copy the matches from the matcher' do
        expect(copy.call(result)).to be == 'block failure'
      end
    end
  end
end
