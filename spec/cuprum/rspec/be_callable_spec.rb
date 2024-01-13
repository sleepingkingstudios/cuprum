# frozen_string_literal: true

require 'cuprum/rspec/be_callable'

RSpec.describe Cuprum::RSpec::Matchers do # rubocop:disable RSpec/FilePath, RSpec/SpecFilePathFormat
  include Cuprum::RSpec::Matchers # rubocop:disable RSpec/DescribedClass

  let(:example_group) { self }

  describe '#be_callable' do
    let(:matcher) { example_group.be_callable }
    let(:matcher_class) do
      RSpec::SleepingKingStudios::Matchers::BuiltIn::RespondToMatcher
    end

    it 'should define the method' do
      expect(example_group)
        .to respond_to(:be_callable)
        .with(0).arguments
    end

    it { expect(matcher).to be_a matcher_class }

    it 'should set the description' do
      expect(matcher.description)
        .to be == 'respond to #process'
    end
  end
end
