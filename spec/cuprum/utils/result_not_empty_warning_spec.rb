require 'cuprum/result'
require 'cuprum/utils/result_not_empty_warning'

RSpec.describe Cuprum::Utils::ResultNotEmptyWarning do
  subject(:instance) { described_class.new(result) }

  let(:value)  { nil }
  let(:errors) { [] }
  let(:result) { Cuprum::Result.new(value: value, :errors => errors) }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(1).argument }
  end # describe

  describe '#message' do
    let(:expected) { '#process returned a result, but ' }

    include_examples 'should have reader', :message, ''

    describe 'when the result has a value' do
      let(:value) { Object.new }

      it { expect(instance.message).to be == '' }
    end # describe

    describe 'when the result has errors' do
      let(:errors) { ['errors.messages.unknown'] }
      let(:expected) do
        super() << "there were already errors #{result.errors.inspect}"
      end # let

      it { expect(instance.message).to be == expected }
    end # describe

    describe 'when the result status is set' do
      let(:result)   { super().failure! }
      let(:expected) { super() << 'the status was set to :failure' }

      it { expect(instance.message).to be == expected }
    end # describe

    describe 'when the result is halted' do
      let(:result)   { super().halt! }
      let(:expected) { super() << 'the command was halted' }

      it { expect(instance.message).to be == expected }
    end # describe

    describe 'when the result has errors and a set status' do
      let(:errors) { ['errors.messages.unknown'] }
      let(:result) { super().success! }
      let(:expected) do
        super() <<
          "there were already errors #{result.errors.inspect}" \
          ' and ' \
          'the status was set to :success'
      end # let

      it { expect(instance.message).to be == expected }
    end # describe

    describe 'when the result has errors, a set status, and is halted' do
      let(:errors) { ['errors.messages.unknown'] }
      let(:result) { super().success!.halt! }
      let(:expected) do
        super() +
          "there were already errors #{result.errors.inspect}" \
          ', ' \
          'the status was set to :success' \
          ', and ' \
          'the command was halted'
      end # let

      it { expect(instance.message).to be == expected }
    end # describe
  end # describe

  describe '#warning?' do
    include_examples 'should have predicate', :warning?, false

    describe 'when the result has a value' do
      let(:value) { Object.new }

      it { expect(instance.warning?).to be false }
    end # describe

    describe 'when the result has errors' do
      let(:errors) { ['errors.messages.unknown'] }

      it { expect(instance.warning?).to be true }
    end # describe

    describe 'when the result status is set' do
      let(:result) { super().failure! }

      it { expect(instance.warning?).to be true }
    end # describe

    describe 'when the result is halted' do
      let(:result) { super().halt! }

      it { expect(instance.warning?).to be true }
    end # describe

    describe 'when the result has errors and a set status' do
      let(:errors) { ['errors.messages.unknown'] }
      let(:result) { super().success! }

      it { expect(instance.warning?).to be true }
    end # describe

    describe 'when the result has errors, a set status, and is halted' do
      let(:errors) { ['errors.messages.unknown'] }
      let(:result) { super().success!.halt! }

      it { expect(instance.warning?).to be true }
    end # describe
  end # describe
end # describe
