# frozen_string_literal: true

require 'cuprum/operation'
require 'cuprum/result'
require 'cuprum/rspec/be_a_result_matcher'

RSpec.describe Cuprum::RSpec::BeAResultMatcher do
  subject(:matcher) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end

  describe '#description' do
    let(:expected) { 'be a Cuprum result' }

    it { expect(matcher).to respond_to(:description).with(0).arguments }

    it { expect(matcher.description).to be == expected }
  end

  describe '#does_not_match?' do
    shared_examples 'should set the failure message' do
      it 'should set the failure message' do
        matcher.matches?(actual)

        expect(matcher.failure_message_when_negated).to be == failure_message
      end
    end

    let(:description)     { 'be a Cuprum result' }
    let(:failure_message) { "expected #{actual.inspect} not to #{description}" }

    it { expect(matcher).to respond_to(:matches?).with(1).argument }

    describe 'with nil' do
      it { expect(matcher.does_not_match? nil).to be true }
    end

    describe 'with an Object' do
      let(:actual) { Object.new.freeze }

      it { expect(matcher.does_not_match? actual).to be true }
    end

    describe 'with a Cuprum result' do
      let(:actual) { Cuprum::Result.new }

      it { expect(matcher.does_not_match? actual).to be false }

      include_examples 'should set the failure message'
    end

    describe 'with an uncalled Cuprum::Operation' do
      let(:actual) { Cuprum::Operation.new }

      it { expect(matcher.does_not_match? actual).to be false }

      include_examples 'should set the failure message'
    end

    describe 'with a called Cuprum::Operation' do
      let(:result) { Cuprum::Result.new }
      let(:actual) { Cuprum::Operation.new { result }.call }

      it { expect(matcher.does_not_match? actual).to be false }

      include_examples 'should set the failure message'
    end

    describe 'with a result-like object' do
      let(:result) { Cuprum::Result.new }
      let(:actual) { Spec::ResultWrapper.new(result) }

      example_class 'Spec::ResultWrapper', Struct.new(:result) do |klass|
        klass.send :alias_method, :to_cuprum_result, :result
      end

      it { expect(matcher.does_not_match? actual).to be false }

      include_examples 'should set the failure message'
    end
  end

  describe '#failure_message' do
    it 'should define the method' do
      expect(matcher).to respond_to(:failure_message).with(0).arguments
    end
  end

  describe '#failure_message_when_negated' do
    it 'should define the method' do
      expect(matcher)
        .to respond_to(:failure_message_when_negated)
        .with(0).arguments
    end
  end

  describe '#matches?' do
    shared_examples 'should set the failure message' do
      it 'should set the failure message' do
        matcher.matches?(actual)

        expect(matcher.failure_message).to be == failure_message
      end
    end

    let(:description)     { 'be a Cuprum result' }
    let(:failure_message) { "expected #{actual.inspect} to #{description}" }

    it { expect(matcher).to respond_to(:matches?).with(1).argument }

    describe 'with nil' do
      let(:actual) { nil }

      it { expect(matcher.matches? nil).to be false }

      include_examples 'should set the failure message'
    end

    describe 'with an Object' do
      let(:actual) { Object.new.freeze }

      it { expect(matcher.matches? actual).to be false }

      include_examples 'should set the failure message'
    end

    describe 'with a Cuprum result' do
      let(:params) { {} }
      let(:actual) { Cuprum::Result.new(params) }

      it { expect(matcher.matches? actual).to be true }
    end

    describe 'with an uncalled Cuprum::Operation' do
      let(:actual) { Cuprum::Operation.new }

      it { expect(matcher.matches? actual).to be false }

      include_examples 'should set the failure message'
    end

    describe 'with a called Cuprum::Operation' do
      let(:params) { {} }
      let(:result) { Cuprum::Result.new(params) }
      let(:actual) { Cuprum::Operation.new { result }.call }

      it { expect(matcher.matches? actual).to be true }
    end

    describe 'with a result-like object' do
      let(:params) { {} }
      let(:result) { Cuprum::Result.new(params) }
      let(:actual) { Spec::ResultWrapper.new(result) }

      example_class 'Spec::ResultWrapper', Struct.new(:result) do |klass|
        klass.send :alias_method, :to_cuprum_result, :result
      end

      it { expect(matcher.matches? actual).to be true }
    end
  end
end
