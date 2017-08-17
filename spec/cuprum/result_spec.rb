require 'cuprum/result'

RSpec.describe Cuprum::Result do
  shared_context 'when the result has many errors' do
    before(:example) do
      instance.errors << { :type => 'errors.messages.unknown' }
    end # before example
  end # shared_context

  subject(:instance) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end # describe

  describe '#errors' do
    include_examples 'should have property', :errors, []
  end # describe

  describe '#failure?' do
    include_examples 'should have predicate', :failure?, false

    wrap_context 'when the result has many errors' do
      it { expect(instance.failure?).to be true }
    end # wrap_context
  end # describe

  describe '#success?' do
    include_examples 'should have predicate', :success?, true

    wrap_context 'when the result has many errors' do
      it { expect(instance.success?).to be false }
    end # wrap_context
  end # describe

  describe '#value' do
    include_examples 'should have property', :value, nil
  end # describe
end # describe
