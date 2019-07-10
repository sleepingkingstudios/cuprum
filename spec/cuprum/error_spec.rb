# frozen_string_literal: true

require 'cuprum/error'

RSpec.describe Cuprum::Error do
  subject(:error) { described_class.new(message: message) }

  let(:message) { nil }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:message)
    end
  end

  describe '#==' do
    shared_context 'when there is an error subclass' do
      example_class 'Spec::Error', described_class
    end

    describe 'with nil' do
      # rubocop:disable Style/NilComparison
      it { expect(error == nil).to be false }
      # rubocop:enable Style/NilComparison
    end

    describe 'with an Object' do
      it { expect(error == Object.new.freeze).to be false }
    end

    describe 'with an Error with no message' do
      let(:other) { described_class.new }

      it { expect(error == other).to be true }
    end

    describe 'with an Error with non-matching message' do
      let(:other) { described_class.new(message: 'An error occurred.') }

      it { expect(error == other).to be false }
    end

    describe 'with an Error subclass with no message' do
      include_context 'when there is an error subclass'

      let(:other) { Spec::Error.new }

      it { expect(error == other).to be false }
    end

    describe 'with an Error subclass with non-matching message' do
      include_context 'when there is an error subclass'

      let(:other) { Spec::Error.new(message: 'An error occurred.') }

      it { expect(error == other).to be false }
    end

    # rubocop:disable RSpec/NestedGroups
    context 'when initialized with a message' do
      let(:message) { 'Something went wrong.' }

      describe 'with nil' do
        # rubocop:disable Style/NilComparison
        it { expect(error == nil).to be false }
        # rubocop:enable Style/NilComparison
      end

      describe 'with an Object' do
        it { expect(error == Object.new.freeze).to be false }
      end

      describe 'with an Error with no message' do
        let(:other) { described_class.new }

        it { expect(error == other).to be false }
      end

      describe 'with an Error with non-matching message' do
        let(:other) { described_class.new(message: 'An error occurred.') }

        it { expect(error == other).to be false }
      end

      describe 'with an Error with matching message' do
        let(:other) { described_class.new(message: message) }

        it { expect(error == other).to be true }
      end

      describe 'with an Error subclass with no message' do
        include_context 'when there is an error subclass'

        let(:other) { Spec::Error.new }

        it { expect(error == other).to be false }
      end

      describe 'with an Error subclass with non-matching message' do
        include_context 'when there is an error subclass'

        let(:other) { Spec::Error.new(message: 'An error occurred.') }

        it { expect(error == other).to be false }
      end

      describe 'with an Error subclass with matching message' do
        include_context 'when there is an error subclass'

        let(:other) { Spec::Error.new(message: message) }

        it { expect(error == other).to be false }
      end
    end
    # rubocop:enable RSpec/NestedGroups
  end

  describe '#message' do
    include_examples 'should have reader', :message, nil

    context 'when initialized with no arguments' do
      subject(:error) { described_class.new }

      it { expect(error.message).to be nil }
    end

    context 'when initialized with a message' do
      let(:message) { 'Something went wrong.' }

      it { expect(error.message).to be == message }
    end
  end
end
