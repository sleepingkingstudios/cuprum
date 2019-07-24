# frozen_string_literal: true

require 'cuprum/rspec/be_a_result'

RSpec.describe RSpec::Matchers do # rubocop:disable RSpec/FilePath
  let(:example_group) { self }

  describe '#be_a_result' do
    let(:matcher) { example_group.be_a_result }

    it { expect(example_group).to respond_to(:be_a_result).with(0).arguments }

    it { expect(matcher).to be_a Cuprum::RSpec::BeAResultMatcher }

    it { expect(matcher.description).to be == 'be a Cuprum result' }
  end
end
