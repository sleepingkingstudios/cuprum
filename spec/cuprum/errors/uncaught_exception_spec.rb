# frozen_string_literal: true

require 'cuprum/errors/uncaught_exception'

RSpec.describe Cuprum::Errors::UncaughtException do
  subject(:error) { described_class.new(exception: exception, **options) }

  let(:exception) do
    raise 'Something went wrong.'
  rescue StandardError => exception
    exception
  end
  let(:options) { {} }

  describe '::TYPE' do
    include_examples 'should define immutable constant',
      :TYPE,
      'cuprum.collections.errors.uncaught_exception'
  end

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:exception, :message)
    end
  end

  describe '#as_json' do
    let(:expected_data) do
      {
        'exception_backtrace' => exception.backtrace,
        'exception_class'     => exception.class,
        'exception_message'   => exception.message
      }
    end
    let(:expected) do
      {
        'data'    => expected_data,
        'message' => error.message,
        'type'    => error.type
      }
    end

    include_examples 'should have reader', :as_json, -> { be == expected }

    context 'when the exception has a cause' do
      let(:raised) do
        raise 'Something went wrong.'
      rescue StandardError => cause
        begin
          raise 'Things got worse.'
        rescue StandardError => exception
          [exception, cause]
        end
      end
      let(:exception) { raised.first }
      let(:cause)     { raised.last }
      let(:expected_data) do
        super().merge(
          {
            'cause_backtrace' => cause.backtrace,
            'cause_class'     => cause.class,
            'cause_message'   => cause.message
          }
        )
      end

      it { expect(error.as_json).to be == expected }
    end
  end

  describe '#exception' do
    include_examples 'should have reader', :exception, -> { exception }
  end

  describe '#message' do
    let(:expected) do
      "uncaught exception #{exception.class}: #{exception.message}"
    end

    include_examples 'should have reader', :message, -> { be == expected }

    context 'when initialized with message: value' do
      let(:message) { 'a fatal error occurred' }
      let(:options) { { message: message } }
      let(:expected) do
        "#{message} #{exception.class}: #{exception.message}"
      end

      it { expect(error.message).to be == expected }
    end

    context 'when the exception has a cause' do
      let(:raised) do
        raise 'Something went wrong.'
      rescue StandardError => cause
        begin
          raise 'Things got worse.'
        rescue StandardError => exception
          [exception, cause]
        end
      end
      let(:exception) { raised.first }
      let(:cause)     { raised.last }
      let(:expected) do
        super() + " caused by #{cause.class}: #{cause.message}"
      end

      it { expect(error.message).to be == expected }
    end
  end

  describe '#type' do
    include_examples 'should define reader', :type, described_class::TYPE
  end
end
