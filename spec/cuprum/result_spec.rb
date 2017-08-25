require 'cuprum/result'

RSpec.describe Cuprum::Result do
  shared_context 'when the result has many errors' do
    before(:example) do
      instance.errors << { :type => 'errors.messages.unknown' }
    end # before example
  end # shared_context

  subject(:instance) { described_class.new }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class).
        to be_constructible.
        with(0..1).arguments.
        and_keywords(:errors)
    end # it

    describe 'with an errors object' do
      let(:errors)   { ['errors.messages.unknown'] }
      let(:instance) { described_class.new(:errors => errors) }

      it { expect(instance.errors).to be errors }

      it { expect(instance.failure?).to be true }
    end # describe

    describe 'with a value' do
      let(:value)    { 'returned value'.freeze }
      let(:instance) { described_class.new(value) }

      it { expect(instance.value).to be value }

      it { expect(instance.success?).to be true }
    end # describe

    describe 'with a value and an errors object' do
      let(:value)    { 'returned value'.freeze }
      let(:errors)   { ['errors.messages.unknown'] }
      let(:instance) { described_class.new(value, :errors => errors) }

      it { expect(instance.value).to be value }

      it { expect(instance.errors).to be errors }

      it { expect(instance.failure?).to be true }
    end # describe
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
