# frozen_string_literal: true

require 'support/results/halting_result'

# @note Integration test for Cuprum::Results with custom statuses.
RSpec.describe Spec::Results::HaltingResult do
  subject(:result) { described_class.new(**constructor_options) }

  let(:constructor_options) { {} }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:error, :status, :value)
    end

    describe 'with an invalid status' do
      let(:error_message) do
        'invalid status :ambiguous'
      end

      it 'should raise an exception' do
        expect { described_class.new(status: :ambiguous) }
          .to raise_error ArgumentError, error_message
      end
    end
  end

  describe '#failure?' do
    it { expect(result.failure?).to be false }

    context 'when initialized with status: :failure' do
      let(:constructor_options) { super().merge(status: :failure) }

      it { expect(result.failure?).to be true }
    end

    context 'when initialized with status: :halted' do
      let(:constructor_options) { super().merge(status: :halted) }

      it { expect(result.failure?).to be false }
    end

    context 'when initialized with status: :success' do
      let(:constructor_options) { super().merge(status: :success) }

      it { expect(result.failure?).to be false }
    end
  end

  describe '#halted?' do
    it { expect(result.halted?).to be false }

    context 'when initialized with status: :failure' do
      let(:constructor_options) { super().merge(status: :failure) }

      it { expect(result.halted?).to be false }
    end

    context 'when initialized with status: :halted' do
      let(:constructor_options) { super().merge(status: :halted) }

      it { expect(result.halted?).to be true }
    end

    context 'when initialized with status: :success' do
      let(:constructor_options) { super().merge(status: :success) }

      it { expect(result.halted?).to be false }
    end
  end

  describe '#status?' do
    it { expect(result.status).to be :success }

    context 'when initialized with status: :failure' do
      let(:constructor_options) { super().merge(status: :failure) }

      it { expect(result.status).to be :failure }
    end

    context 'when initialized with status: :halted' do
      let(:constructor_options) { super().merge(status: :halted) }

      it { expect(result.status).to be :halted }
    end

    context 'when initialized with status: :success' do
      let(:constructor_options) { super().merge(status: :success) }

      it { expect(result.status).to be :success }
    end
  end

  describe '#success?' do
    it { expect(result.success?).to be true }

    context 'when initialized with status: :failure' do
      let(:constructor_options) { super().merge(status: :failure) }

      it { expect(result.success?).to be false }
    end

    context 'when initialized with status: :halted' do
      let(:constructor_options) { super().merge(status: :halted) }

      it { expect(result.success?).to be false }
    end

    context 'when initialized with status: :success' do
      let(:constructor_options) { super().merge(status: :success) }

      it { expect(result.success?).to be true }
    end
  end
end
