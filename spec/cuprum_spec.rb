# frozen_string_literal: true

require 'cuprum'

RSpec.describe Cuprum do
  describe '::VERSION' do
    it 'should define the constant' do
      expect(described_class)
        .to have_constant(:VERSION)
        .with_value(Cuprum::Version.to_gem_version)
    end
  end

  describe '.initializer' do
    include_examples 'should define class reader',
      :initializer,
      -> { be_a(SleepingKingStudios::Tools::Toolbox::Initializer) }
  end

  describe '.version' do
    it 'should define the reader' do
      expect(described_class)
        .to have_reader(:version)
        .with_value(Cuprum::Version.to_gem_version)
    end
  end
end
