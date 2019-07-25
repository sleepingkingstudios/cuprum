# frozen_string_literal: true

require 'cuprum/rspec/be_a_result'

RSpec.describe RSpec::Matchers do # rubocop:disable RSpec/FilePath
  let(:example_group) { self }

  describe '#be_a_failing_result' do
    let(:matcher) { example_group.be_a_failing_result }

    it 'should define the method' do
      expect(example_group)
        .to respond_to(:be_a_failing_result)
        .with(0).arguments
    end

    it { expect(matcher).to be_a Cuprum::RSpec::BeAResultMatcher }

    it 'should set the description' do
      expect(matcher.description)
        .to be == 'be a Cuprum result with status: :failure'
    end
  end

  describe '#be_a_passing_result' do
    let(:matcher) { example_group.be_a_passing_result }

    it 'should define the method' do
      expect(example_group)
        .to respond_to(:be_a_passing_result)
        .with(0).arguments
    end

    it { expect(matcher).to be_a Cuprum::RSpec::BeAResultMatcher }

    it 'should set the description' do
      expect(matcher.description)
        .to be == 'be a Cuprum result with status: :success'
    end
  end

  describe '#be_a_result' do
    let(:matcher) { example_group.be_a_result }

    it { expect(example_group).to respond_to(:be_a_result).with(0).arguments }

    it { expect(matcher).to be_a Cuprum::RSpec::BeAResultMatcher }

    it { expect(matcher.description).to be == 'be a Cuprum result' }
  end
end
