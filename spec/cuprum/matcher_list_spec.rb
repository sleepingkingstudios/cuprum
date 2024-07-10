# frozen_string_literal: true

require 'cuprum/matcher'
require 'cuprum/matcher_list'

RSpec.describe Cuprum::MatcherList do
  subject(:matcher_list) { described_class.new(matchers) }

  let(:matchers) { [] }

  describe '.new' do
    it { expect(described_class).to respond_to(:new).with(1).argument }
  end

  describe '#call' do
    example_class 'Spec::CustomError', Cuprum::Error

    example_class 'Spec::RocketPart'

    it { expect(matcher_list).to respond_to(:call).with(1).argument }

    describe 'with nil' do
      let(:error_message) { 'result must be a Cuprum::Result' }

      it 'should raise an exception' do
        expect { matcher_list.call(nil) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with an Object' do
      let(:error_message) { 'result must be a Cuprum::Result' }

      it 'should raise an exception' do
        expect { matcher_list.call(Object.new.freeze) }
          .to raise_error ArgumentError, error_message
      end
    end

    describe 'with a result' do
      let(:result)        { Cuprum::Result.new }
      let(:error_message) { "no match found for #{result.inspect}" }

      it 'should raise an exception' do
        expect { matcher_list.call(result) }
          .to raise_error Cuprum::Matching::NoMatchError, error_message
      end
    end

    context 'when initialized with a matcher' do
      let(:matchers) { [Cuprum::Matcher.new] }
      let(:error) { Spec::CustomError.new }
      let(:value) { Spec::RocketPart.new }
      let(:result) do
        Cuprum::Result.new(
          status: :failure,
          error:,
          value:
        )
      end

      describe 'with a non-matching result' do
        let(:error_message) { "no match found for #{result.inspect}" }

        it 'should raise an exception' do
          expect { matcher_list.call(result) }
            .to raise_error Cuprum::Matching::NoMatchError, error_message
        end
      end

      describe 'with an exact match' do
        let(:matchers) do
          error = Spec::CustomError
          value = Spec::RocketPart

          [
            Cuprum::Matcher.new do
              match(:failure, error:, value:) do
                'failure with value and error'
              end
            end
          ]
        end
        let(:expected) { 'failure with value and error' }

        it { expect(matcher_list.call(result)).to be == expected }
      end

      describe 'with a partial error match' do
        let(:matchers) do
          error = Spec::CustomError

          [
            Cuprum::Matcher.new do
              match(:failure, error:) do
                'failure with error'
              end
            end
          ]
        end
        let(:expected) { 'failure with error' }

        it { expect(matcher_list.call(result)).to be == expected }
      end

      describe 'with a partial value match' do
        let(:matchers) do
          value = Spec::RocketPart

          [
            Cuprum::Matcher.new do
              match(:failure, value:) do
                'failure with value'
              end
            end
          ]
        end
        let(:expected) { 'failure with value' }

        it { expect(matcher_list.call(result)).to be == expected }
      end

      describe 'with a generic match' do
        let(:matchers) do
          [
            Cuprum::Matcher.new do
              match(:failure) do
                'failure'
              end
            end
          ]
        end
        let(:expected) { 'failure' }

        it { expect(matcher_list.call(result)).to be == expected }
      end
    end

    context 'when initialized with a matcher with many clauses' do
      let(:matchers) do
        error = Spec::CustomError
        value = Spec::RocketPart

        [
          Cuprum::Matcher.new do
            match(:failure, error:, value:) do
              'failure with value and error'
            end

            match(:failure, error:) { 'failure with error' }

            match(:failure) { 'failure' }
          end
        ]
      end

      describe 'with a non-matching result' do
        let(:result)        { Cuprum::Result.new(status: :success) }
        let(:error_message) { "no match found for #{result.inspect}" }

        it 'should raise an exception' do
          expect { matcher_list.call(result) }
            .to raise_error Cuprum::Matching::NoMatchError, error_message
        end
      end

      describe 'with an exact match' do
        let(:error) { Spec::CustomError.new }
        let(:value) { Spec::RocketPart.new }
        let(:result) do
          Cuprum::Result.new(
            status: :failure,
            error:,
            value:
          )
        end
        let(:expected) { 'failure with value and error' }

        it { expect(matcher_list.call(result)).to be == expected }
      end

      describe 'with a partial match' do
        let(:error) { Spec::CustomError.new }
        let(:result) do
          Cuprum::Result.new(
            status: :failure,
            error:
          )
        end
        let(:expected) { 'failure with error' }

        it { expect(matcher_list.call(result)).to be == expected }
      end

      describe 'with a generic match' do
        let(:error)    { Spec::CustomError.new }
        let(:result)   { Cuprum::Result.new(status: :failure) }
        let(:expected) { 'failure' }

        it { expect(matcher_list.call(result)).to be == expected }
      end
    end

    context 'when initialized with many matchers' do
      let(:matchers) do
        error = Spec::CustomError
        value = Spec::RocketPart

        [
          Cuprum::Matcher.new do
            match(:failure) { 'first: failure' }
          end,
          Cuprum::Matcher.new do
            match(:failure, error:) { 'mid: failure with error' }

            match(:failure) { 'mid: failure' }
          end,
          Cuprum::Matcher.new do
            match(:failure, error:, value:) do
              'last: failure with value and error'
            end

            match(:failure, error:) { 'last: failure with error' }

            match(:failure) { 'last: failure' }
          end
        ]
      end

      describe 'with a non-matching result' do
        let(:result)        { Cuprum::Result.new(status: :success) }
        let(:error_message) { "no match found for #{result.inspect}" }

        it 'should raise an exception' do
          expect { matcher_list.call(result) }
            .to raise_error Cuprum::Matching::NoMatchError, error_message
        end
      end

      describe 'with an exact match' do
        let(:error) { Spec::CustomError.new }
        let(:value) { Spec::RocketPart.new }
        let(:result) do
          Cuprum::Result.new(
            status: :failure,
            error:,
            value:
          )
        end
        let(:expected) { 'last: failure with value and error' }

        it { expect(matcher_list.call(result)).to be == expected }
      end

      describe 'with a partial match' do
        let(:error) { Spec::CustomError.new }
        let(:result) do
          Cuprum::Result.new(
            status: :failure,
            error:
          )
        end
        let(:expected) { 'mid: failure with error' }

        it { expect(matcher_list.call(result)).to be == expected }
      end

      describe 'with a generic match' do
        let(:error)    { Spec::CustomError.new }
        let(:result)   { Cuprum::Result.new(status: :failure) }
        let(:expected) { 'first: failure' }

        it { expect(matcher_list.call(result)).to be == expected }
      end
    end
  end

  describe '#matchers' do
    include_examples 'should define reader', :matchers, -> { matchers }
  end
end
