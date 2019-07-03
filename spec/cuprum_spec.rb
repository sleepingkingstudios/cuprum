# spec/cuprum_spec.rb

require 'cuprum'

RSpec.describe Cuprum do
  describe '::VERSION' do
    it 'should define the constant' do
      expect(described_class).
        to have_constant(:VERSION).
        with_value(Cuprum::Version.to_gem_version)
    end # it
  end # describe

  describe '::version' do
    it 'should define the reader' do
      expect(described_class).
        to have_reader(:version).
        with_value(Cuprum::Version.to_gem_version)
    end # it
  end # describe
end # describe
