# frozen_string_literal: true

require 'support/results/result_with_checksum'

RSpec.describe Spec::Results::ResultWithChecksum do
  subject(:result) { described_class.new(**constructor_options) }

  let(:constructor_options) { {} }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:checksum, :error, :status, :value)
    end
  end

  describe '#==' do
    describe 'with a base result with non-matching properties' do
      let(:other) { Cuprum::Result.new(value: { ok: true }) }

      it { expect(result == other).to be false }
    end

    describe 'with a base result with matching properties' do
      let(:other) { Cuprum::Result.new }

      it { expect(result == other).to be false }
    end

    describe 'with a result with non-matching checksum' do
      let(:other) { described_class.new(checksum: '67890') }

      it { expect(result == other).to be false }
    end

    describe 'with a result with non-matching properties' do
      let(:other) { described_class.new(value: { ok: true }) }

      it { expect(result == other).to be false }
    end

    describe 'with a result with matching checksum and properties' do
      let(:other) { described_class.new }

      it { expect(result == other).to be true }
    end

    context 'when initialized with a checksum and result properties' do
      let(:checksum) { '12345' }
      let(:value)    { { ok: false } }
      let(:error)    { Cuprum::Error.new(message: 'Something went wrong') }
      let(:constructor_options) do
        super().merge(value:, error:)
      end

      describe 'with a base result with non-matching properties' do
        let(:other) { Cuprum::Result.new(value: { ok: true }) }

        it { expect(result == other).to be false }
      end

      describe 'with a base result with matching properties' do
        let(:other) { Cuprum::Result.new(value:, error:) }

        it { expect(result == other).to be false }
      end

      describe 'with a result with non-matching checksum' do
        let(:other) do
          described_class.new(value:, error:, checksum: '67890')
        end

        it { expect(result == other).to be false }
      end

      describe 'with a result with non-matching properties' do
        let(:other) do
          described_class.new(value: { ok: true }, checksum:)
        end

        it { expect(result == other).to be false }
      end

      describe 'with a result with matching checksum and properties' do
        let(:other) { described_class.new(**constructor_options) }

        it { expect(result == other).to be true }
      end
    end
  end

  describe '#checksum' do
    include_examples 'should define reader', :checksum, nil

    context 'when initialized with a checksum' do
      let(:checksum)            { '12345' }
      let(:constructor_options) { super().merge(checksum:) }

      it { expect(result.checksum).to be == checksum }
    end
  end

  describe '#properties' do
    let(:expected) do
      {
        checksum: result.checksum,
        error:    result.error,
        status:   result.status,
        value:    result.value
      }
    end

    it { expect(result.properties).to be == expected }

    context 'when initialized with a checksum' do
      let(:checksum)            { '12345' }
      let(:constructor_options) { super().merge(checksum:) }

      it { expect(result.properties).to be == expected }
    end

    context 'when initialized with result properties' do
      let(:value) { { ok: false } }
      let(:error) { Cuprum::Error.new(message: 'Something went wrong') }
      let(:constructor_options) do
        super().merge(value:, error:)
      end

      it { expect(result.properties).to be == expected }
    end

    context 'when initialized with a checksum and result properties' do
      let(:checksum) { '12345' }
      let(:value)    { { ok: false } }
      let(:error)    { Cuprum::Error.new(message: 'Something went wrong') }
      let(:constructor_options) do
        super().merge(value:, error:)
      end

      it { expect(result.properties).to be == expected }
    end
  end
end
