# frozen_string_literal: true

require 'cuprum/operation'
require 'cuprum/result'
require 'cuprum/rspec/be_a_result_matcher'

require 'support/halting_result'

RSpec.describe Cuprum::RSpec::BeAResultMatcher do
  shared_context 'with a status expectation' do
    let(:expected_status) { defined?(super()) ? super() : :success }
    let(:matcher)         { super().with_status(expected_status) }
  end

  shared_context 'with a value expectation' do
    let(:expected_value) { defined?(super()) ? super() : 'returned value' }
    let(:matcher)        { super().with_value(expected_value) }
  end

  subject(:matcher) { described_class.new }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end

  describe '#description' do
    let(:expected) { 'be a Cuprum result' }

    it { expect(matcher).to respond_to(:description).with(0).arguments }

    it { expect(matcher.description).to be == expected }

    wrap_context 'with a status expectation' do
      let(:expected) { super() + " with status: #{expected_status.inspect}" }

      it { expect(matcher.description).to be == expected }
    end

    wrap_context 'with a value expectation' do
      let(:expected) { super() + ' with the expected value' }

      it { expect(matcher.description).to be == expected }
    end

    context 'with a status and a value expectation' do
      let(:expected_status) { :success }
      let(:expected_value)  { 'returned value' }
      let(:matcher) do
        super().with_value(expected_value).and_status(expected_status)
      end
      let(:expected) do
        super() +
          " with the expected value and status: #{expected_status.inspect}"
      end

      it { expect(matcher.description).to be == expected }
    end
  end

  describe '#does_not_match?' do
    shared_examples 'should set the failure message' do
      it 'should set the failure message' do
        matcher.matches?(actual)

        expect(matcher.failure_message_when_negated).to be == failure_message
      end
    end

    let(:description)     { 'be a Cuprum result' }
    let(:failure_message) { "expected #{actual.inspect} not to #{description}" }

    it { expect(matcher).to respond_to(:matches?).with(1).argument }

    describe 'with nil' do
      it { expect(matcher.does_not_match? nil).to be true }
    end

    describe 'with an Object' do
      let(:actual) { Object.new.freeze }

      it { expect(matcher.does_not_match? actual).to be true }
    end

    describe 'with a Cuprum result' do
      let(:actual) { Cuprum::Result.new }

      it { expect(matcher.does_not_match? actual).to be false }

      include_examples 'should set the failure message'
    end

    describe 'with an uncalled Cuprum::Operation' do
      let(:actual) { Cuprum::Operation.new }

      it { expect(matcher.does_not_match? actual).to be false }

      include_examples 'should set the failure message'
    end

    describe 'with a called Cuprum::Operation' do
      let(:result) { Cuprum::Result.new }
      let(:actual) { Cuprum::Operation.new { result }.call }

      it { expect(matcher.does_not_match? actual).to be false }

      include_examples 'should set the failure message'
    end

    describe 'with a result-like object' do
      let(:result) { Cuprum::Result.new }
      let(:actual) { Spec::ResultWrapper.new(result) }

      example_class 'Spec::ResultWrapper', Struct.new(:result) do |klass|
        klass.send :alias_method, :to_cuprum_result, :result
      end

      it { expect(matcher.does_not_match? actual).to be false }

      include_examples 'should set the failure message'
    end

    wrap_context 'with a status expectation' do
      let(:error_message) do
        'Using `expect().not_to be_a_result.with_status()` risks false' \
        ' positives, since any other result will match.'
      end

      it 'should raise an error' do
        expect { matcher.does_not_match? nil }
          .to raise_error ArgumentError, error_message
      end
    end

    wrap_context 'with a value expectation' do
      let(:error_message) do
        'Using `expect().not_to be_a_result.with_value()` risks false' \
        ' positives, since any other result will match.'
      end

      it 'should raise an error' do
        expect { matcher.does_not_match? nil }
          .to raise_error ArgumentError, error_message
      end
    end

    context 'with a status and a value expectation' do
      let(:expected_status) { :success }
      let(:expected_value)  { 'returned value' }
      let(:matcher) do
        super().with_value(expected_value).and_status(expected_status)
      end
      let(:error_message) do
        'Using `expect().not_to be_a_result.with_value().and_status()` risks' \
        ' false positives, since any other result will match.'
      end

      it 'should raise an error' do
        expect { matcher.does_not_match? nil }
          .to raise_error ArgumentError, error_message
      end
    end
  end

  describe '#failure_message' do
    it 'should define the method' do
      expect(matcher).to respond_to(:failure_message).with(0).arguments
    end
  end

  describe '#failure_message_when_negated' do
    it 'should define the method' do
      expect(matcher)
        .to respond_to(:failure_message_when_negated)
        .with(0).arguments
    end
  end

  # rubocop:disable RSpec/NestedGroups
  describe '#matches?' do
    shared_examples 'should set the failure message' do
      it 'should set the failure message' do
        matcher.matches?(actual)

        expect(matcher.failure_message).to be == failure_message
      end
    end

    let(:description)     { 'be a Cuprum result' }
    let(:failure_message) { "expected #{actual.inspect} to #{description}" }

    it { expect(matcher).to respond_to(:matches?).with(1).argument }

    describe 'with nil' do
      let(:actual) { nil }
      let(:failure_message) do
        super() + ', but the object is not a result'
      end

      it { expect(matcher.matches? nil).to be false }

      include_examples 'should set the failure message'
    end

    describe 'with an Object' do
      let(:actual) { Object.new.freeze }
      let(:failure_message) do
        super() + ', but the object is not a result'
      end

      it { expect(matcher.matches? actual).to be false }

      include_examples 'should set the failure message'
    end

    describe 'with a Cuprum result' do
      let(:actual) { Cuprum::Result.new }

      it { expect(matcher.matches? actual).to be true }
    end

    describe 'with an uncalled Cuprum::Operation' do
      let(:actual) { Cuprum::Operation.new }
      let(:failure_message) do
        super() + ', but the object is an uncalled operation'
      end

      it { expect(matcher.matches? actual).to be false }

      include_examples 'should set the failure message'
    end

    describe 'with a called Cuprum::Operation' do
      let(:actual) { Cuprum::Operation.new.call }

      it { expect(matcher.matches? actual).to be true }
    end

    describe 'with a result-like object' do
      let(:result) { Cuprum::Result.new }
      let(:actual) { Spec::ResultWrapper.new(result) }

      example_class 'Spec::ResultWrapper', Struct.new(:result) do |klass|
        klass.send :alias_method, :to_cuprum_result, :result
      end

      it { expect(matcher.matches? actual).to be true }
    end

    wrap_context 'with a status expectation' do
      shared_examples 'should match the result status' do
        describe 'with a non-matching status' do
          let(:params) { { status: :failure } }
          let(:failure_message) do
            super() + ', but the status does not match:' \
              "\n  expected status: #{expected_status.inspect}" \
              "\n    actual status: #{params[:status].inspect}"
          end

          it { expect(matcher.matches? actual).to be false }

          include_examples 'should set the failure message'
        end

        describe 'with a matching status' do
          let(:params) { { status: :success } }

          it { expect(matcher.matches? actual).to be true }
        end
      end

      let(:expected_status) { :success }
      let(:description) do
        super() + " with status: #{expected_status.inspect}"
      end

      describe 'with nil' do
        let(:actual) { nil }
        let(:failure_message) do
          super() + ', but the object is not a result'
        end

        it { expect(matcher.matches? nil).to be false }

        include_examples 'should set the failure message'
      end

      describe 'with an Object' do
        let(:actual) { Object.new.freeze }
        let(:failure_message) do
          super() + ', but the object is not a result'
        end

        it { expect(matcher.matches? actual).to be false }

        include_examples 'should set the failure message'
      end

      describe 'with a Cuprum result' do
        let(:params) { {} }
        let(:actual) { Cuprum::Result.new(params) }

        include_examples 'should match the result status'
      end

      describe 'with an uncalled Cuprum::Operation' do
        let(:actual) { Cuprum::Operation.new }
        let(:failure_message) do
          super() + ', but the object is an uncalled operation'
        end

        it { expect(matcher.matches? actual).to be false }

        include_examples 'should set the failure message'
      end

      describe 'with a called Cuprum::Operation' do
        let(:params) { {} }
        let(:result) { Cuprum::Result.new(params) }
        let(:actual) do
          returned = result

          Cuprum::Operation.new { returned }.call
        end

        include_examples 'should match the result status'
      end

      describe 'with a custom result object' do
        let(:params) { {} }
        let(:actual) { Spec::HaltingResult.new(params) }
        let(:failure_message) do
          super() + ', but the status does not match:' \
            "\n  expected status: #{expected_status.inspect}" \
            "\n    actual status: #{params[:status].inspect}"
        end

        describe 'with status: :failure' do
          let(:params) { { status: :failure } }

          it { expect(matcher.matches? actual).to be false }

          include_examples 'should set the failure message'
        end

        describe 'with status: :halted' do
          let(:params) { { status: :halted } }

          it { expect(matcher.matches? actual).to be false }

          include_examples 'should set the failure message'
        end

        describe 'with status: :success' do
          let(:params) { { status: :success } }

          it { expect(matcher.matches? actual).to be true }
        end

        context 'when the expected status is a custom status' do
          let(:expected_status) { :halted }

          describe 'with status: :failure' do
            let(:params) { { status: :failure } }

            it { expect(matcher.matches? actual).to be false }

            include_examples 'should set the failure message'
          end

          describe 'with status: :halted' do
            let(:params) { { status: :halted } }

            it { expect(matcher.matches? actual).to be true }
          end

          describe 'with status: :success' do
            let(:params) { { status: :success } }

            it { expect(matcher.matches? actual).to be false }

            include_examples 'should set the failure message'
          end
        end
      end
    end

    describe 'with expected value: nil' do
      include_context 'with a value expectation'

      shared_examples 'should match the result value' do
        describe 'with a non-matching value' do
          let(:params) { { value: 'other value' } }
          let(:failure_message) do
            super() + ', but the value does not match:' \
              "\n   expected value: #{expected_value.inspect}" \
              "\n     actual value: #{params[:value].inspect}"
          end

          it { expect(matcher.matches? actual).to be false }

          include_examples 'should set the failure message'
        end

        describe 'with a matching status' do
          let(:params) { { value: nil } }

          it { expect(matcher.matches? actual).to be true }
        end
      end

      let(:expected_value) { nil }
      let(:description) do
        super() + ' with the expected value'
      end

      describe 'with nil' do
        let(:actual) { nil }
        let(:failure_message) do
          super() + ', but the object is not a result'
        end

        it { expect(matcher.matches? nil).to be false }

        include_examples 'should set the failure message'
      end

      describe 'with an Object' do
        let(:actual) { Object.new.freeze }
        let(:failure_message) do
          super() + ', but the object is not a result'
        end

        it { expect(matcher.matches? actual).to be false }

        include_examples 'should set the failure message'
      end

      describe 'with a Cuprum result' do
        let(:params) { {} }
        let(:actual) { Cuprum::Result.new(params) }

        include_examples 'should match the result value'
      end

      describe 'with an uncalled Cuprum::Operation' do
        let(:actual) { Cuprum::Operation.new }
        let(:failure_message) do
          super() + ', but the object is an uncalled operation'
        end

        it { expect(matcher.matches? actual).to be false }

        include_examples 'should set the failure message'
      end

      describe 'with a called Cuprum::Operation' do
        let(:params) { {} }
        let(:result) { Cuprum::Result.new(params) }
        let(:actual) do
          returned = result

          Cuprum::Operation.new { returned }.call
        end

        include_examples 'should match the result value'
      end
    end

    describe 'with expected value: value' do
      include_context 'with a value expectation'

      shared_examples 'should match the result value' do
        describe 'with a non-matching value' do
          let(:params) { { value: 'other value' } }
          let(:failure_message) do
            super() + ', but the value does not match:' \
              "\n   expected value: #{expected_value.inspect}" \
              "\n     actual value: #{params[:value].inspect}"
          end

          it { expect(matcher.matches? actual).to be false }

          include_examples 'should set the failure message'
        end

        describe 'with a matching status' do
          let(:params) { { value: 'returned value' } }

          it { expect(matcher.matches? actual).to be true }
        end
      end

      let(:description) do
        super() + ' with the expected value'
      end

      describe 'with nil' do
        let(:actual) { nil }
        let(:failure_message) do
          super() + ', but the object is not a result'
        end

        it { expect(matcher.matches? nil).to be false }

        include_examples 'should set the failure message'
      end

      describe 'with an Object' do
        let(:actual) { Object.new.freeze }
        let(:failure_message) do
          super() + ', but the object is not a result'
        end

        it { expect(matcher.matches? actual).to be false }

        include_examples 'should set the failure message'
      end

      describe 'with a Cuprum result' do
        let(:params) { {} }
        let(:actual) { Cuprum::Result.new(params) }

        include_examples 'should match the result value'
      end

      describe 'with an uncalled Cuprum::Operation' do
        let(:actual) { Cuprum::Operation.new }
        let(:failure_message) do
          super() + ', but the object is an uncalled operation'
        end

        it { expect(matcher.matches? actual).to be false }

        include_examples 'should set the failure message'
      end

      describe 'with a called Cuprum::Operation' do
        let(:params) { {} }
        let(:result) { Cuprum::Result.new(params) }
        let(:actual) do
          returned = result

          Cuprum::Operation.new { returned }.call
        end

        include_examples 'should match the result value'
      end
    end

    describe 'with expected value: matcher' do
      include_context 'with a value expectation'

      shared_examples 'should match the result value' do
        describe 'with a non-matching value' do
          let(:params) { { value: :a_symbol } }
          let(:failure_message) do
            super() + ', but the value does not match:' \
              "\n   expected value: #{expected_value.description}" \
              "\n     actual value: #{params[:value].inspect}"
          end

          it { expect(matcher.matches? actual).to be false }

          include_examples 'should set the failure message'
        end

        describe 'with a matching status' do
          let(:params) { { value: 'a string' } }

          it { expect(matcher.matches? actual).to be true }
        end
      end

      let(:expected_value) { an_instance_of(String) }
      let(:description) do
        super() + ' with the expected value'
      end

      describe 'with nil' do
        let(:actual) { nil }
        let(:failure_message) do
          super() + ', but the object is not a result'
        end

        it { expect(matcher.matches? nil).to be false }

        include_examples 'should set the failure message'
      end

      describe 'with an Object' do
        let(:actual) { Object.new.freeze }
        let(:failure_message) do
          super() + ', but the object is not a result'
        end

        it { expect(matcher.matches? actual).to be false }

        include_examples 'should set the failure message'
      end

      describe 'with a Cuprum result' do
        let(:params) { {} }
        let(:actual) { Cuprum::Result.new(params) }

        include_examples 'should match the result value'
      end

      describe 'with an uncalled Cuprum::Operation' do
        let(:actual) { Cuprum::Operation.new }
        let(:failure_message) do
          super() + ', but the object is an uncalled operation'
        end

        it { expect(matcher.matches? actual).to be false }

        include_examples 'should set the failure message'
      end

      describe 'with a called Cuprum::Operation' do
        let(:params) { {} }
        let(:result) { Cuprum::Result.new(params) }
        let(:actual) do
          returned = result

          Cuprum::Operation.new { returned }.call
        end

        include_examples 'should match the result value'
      end
    end

    describe 'with a status and a value expectation' do
      shared_examples 'should match the result status and value' do
        describe 'with a non-matching status and value' do
          let(:params) { { status: :failure, value: 'other value' } }
          let(:failure_message) do
            super() + ', but the status and value do not match:' \
              "\n  expected status: #{expected_status.inspect}" \
              "\n    actual status: #{params[:status].inspect}" \
              "\n   expected value: #{expected_value.inspect}" \
              "\n     actual value: #{params[:value].inspect}"
          end

          it { expect(matcher.matches? actual).to be false }

          include_examples 'should set the failure message'
        end

        describe 'with a non-matching status' do
          let(:params) { { status: :failure, value: expected_value } }
          let(:failure_message) do
            super() + ', but the status does not match:' \
              "\n  expected status: #{expected_status.inspect}" \
              "\n    actual status: #{params[:status].inspect}"
          end

          it { expect(matcher.matches? actual).to be false }

          include_examples 'should set the failure message'
        end

        describe 'with a non-matching value' do
          let(:params) { { status: expected_status, value: 'other value' } }
          let(:failure_message) do
            super() + ', but the value does not match:' \
              "\n   expected value: #{expected_value.inspect}" \
              "\n     actual value: #{params[:value].inspect}"
          end

          it { expect(matcher.matches? actual).to be false }

          include_examples 'should set the failure message'
        end

        describe 'with a matching status and value' do
          let(:params) { { status: expected_status, value: expected_value } }

          it { expect(matcher.matches? actual).to be true }
        end
      end

      let(:expected_status) { :success }
      let(:expected_value)  { 'returned value' }
      let(:matcher) do
        super().with_value(expected_value).and_status(expected_status)
      end
      let(:description) do
        super() + ' with the expected value and status: :success'
      end

      describe 'with nil' do
        let(:actual) { nil }
        let(:failure_message) do
          super() + ', but the object is not a result'
        end

        it { expect(matcher.matches? nil).to be false }

        include_examples 'should set the failure message'
      end

      describe 'with an Object' do
        let(:actual) { Object.new.freeze }
        let(:failure_message) do
          super() + ', but the object is not a result'
        end

        it { expect(matcher.matches? actual).to be false }

        include_examples 'should set the failure message'
      end

      describe 'with a Cuprum result' do
        let(:params) { {} }
        let(:actual) { Cuprum::Result.new(params) }

        include_examples 'should match the result status and value'
      end

      describe 'with an uncalled Cuprum::Operation' do
        let(:actual) { Cuprum::Operation.new }
        let(:failure_message) do
          super() + ', but the object is an uncalled operation'
        end

        it { expect(matcher.matches? actual).to be false }

        include_examples 'should set the failure message'
      end

      describe 'with a called Cuprum::Operation' do
        let(:params) { {} }
        let(:result) { Cuprum::Result.new(params) }
        let(:actual) do
          returned = result

          Cuprum::Operation.new { returned }.call
        end

        include_examples 'should match the result status and value'
      end
    end
  end
  # rubocop:enable RSpec/NestedGroups

  describe '#with_status' do
    it { expect(matcher).to respond_to(:with_status).with(1).argument }

    it { expect(matcher).to alias_method(:with_status).as(:and_status) }

    it { expect(matcher.with_status :success).to be matcher }
  end

  describe '#with_value' do
    it { expect(matcher).to respond_to(:with_value).with(1).argument }

    it { expect(matcher).to alias_method(:with_value).as(:and_value) }

    it { expect(matcher.with_value 'returned value').to be matcher }
  end
end
