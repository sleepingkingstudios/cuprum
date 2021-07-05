# frozen_string_literal: true

require 'cuprum/matching/match_clause'

RSpec.describe Cuprum::Matching::MatchClause do
  subject(:match_clause) { described_class.new(block, error, status, value) }

  let(:block)  { -> {} }
  let(:error)  { nil }
  let(:status) { :success }
  let(:value)  { nil }

  it { expect(described_class).to be < Comparable }

  describe '.new' do
    it { expect(described_class).to respond_to(:new).with(4).arguments }
  end

  describe '#<=>' do
    let(:other_error) { nil }
    let(:other_value) { nil }
    let(:other) do
      described_class.new(block, other_error, status, other_value)
    end

    example_class 'Spec::Error', Cuprum::Error

    example_class 'Spec::Value'

    it { expect(match_clause).to respond_to(:<=>).with(1).argument }

    describe 'with nil' do
      it { expect(match_clause <=> nil).to be nil }
    end

    describe 'with an Object' do
      it { expect(match_clause <=> Object.new.freeze).to be nil }
    end

    describe 'with a clause' do
      it { expect(match_clause <=> other).to be 0 }
    end

    describe 'with a clause with an error' do
      let(:other_error) { Spec::Error }

      it { expect(match_clause <=> other).to be 1 }
    end

    describe 'with a clause with a value' do
      let(:other_value) { Spec::Value }

      it { expect(match_clause <=> other).to be 1 }
    end

    describe 'with a clause with a value and an error' do
      let(:other_error) { Spec::Error }
      let(:other_value) { Spec::Value }

      it { expect(match_clause <=> other).to be 1 }
    end

    context 'when initialized with an error' do
      let(:error) { Spec::Error }

      describe 'with a clause' do
        it { expect(match_clause <=> other).to be(-1) }
      end

      describe 'with a clause with the same error' do
        let(:other_error) { Spec::Error }

        it { expect(match_clause <=> other).to be 0 }
      end

      describe 'with a clause with a superclass error' do
        let(:other_error) { Cuprum::Error }

        it { expect(match_clause <=> other).to be(-1) }
      end

      describe 'with a clause with a subclass error' do
        let(:error)       { Cuprum::Error }
        let(:other_error) { Spec::Error }

        it { expect(match_clause <=> other).to be 1 }
      end

      describe 'with a clause with an unrelated error' do
        let(:other_error) { Class.new(Cuprum::Error) }

        it { expect(match_clause <=> other).to be 0 }
      end

      describe 'with a clause with a value' do
        let(:other_value) { Spec::Value }

        it { expect(match_clause <=> other).to be 1 }
      end

      describe 'with a clause with a value and the same error' do
        let(:other_error) { Spec::Error }
        let(:other_value) { Spec::Value }

        it { expect(match_clause <=> other).to be 1 }
      end

      describe 'with a clause with a value and a superclass error' do
        let(:other_error) { Cuprum::Error }
        let(:other_value) { Spec::Value }

        it { expect(match_clause <=> other).to be 1 }
      end

      describe 'with a clause with a value and a subclass error' do
        let(:error)       { Cuprum::Error }
        let(:other_error) { Spec::Error }
        let(:other_value) { Spec::Value }

        it { expect(match_clause <=> other).to be 1 }
      end

      describe 'with a clause with a value and an unrelated error' do
        let(:other_error) { Class.new(Cuprum::Error) }
        let(:other_value) { Spec::Value }

        it { expect(match_clause <=> other).to be 1 }
      end
    end

    context 'when initialized with a value' do
      let(:value) { Spec::Value }

      example_class 'Spec::CustomValue', 'Spec::Value'

      describe 'with a clause' do
        it { expect(match_clause <=> other).to be(-1) }
      end

      describe 'with a clause with an error' do
        let(:other_error) { Spec::Error }

        it { expect(match_clause <=> other).to be(-1) }
      end

      describe 'with a clause with the same value' do
        let(:other_value) { Spec::Value }

        it { expect(match_clause <=> other).to be 0 }
      end

      describe 'with a clause with the same value and an error' do
        let(:other_error) { Spec::Error }
        let(:other_value) { Spec::Value }

        it { expect(match_clause <=> other).to be 1 }
      end

      describe 'with a clause with a superclass value' do
        let(:value)       { Spec::CustomValue }
        let(:other_value) { Spec::Value }

        it { expect(match_clause <=> other).to be(-1) }
      end

      describe 'with a clause with a superclass value and an error' do
        let(:value)       { Spec::CustomValue }
        let(:other_error) { Spec::Error }
        let(:other_value) { Spec::Value }

        it { expect(match_clause <=> other).to be(-1) }
      end

      describe 'with a clause with a subclass value' do
        let(:other_value) { Spec::CustomValue }

        it { expect(match_clause <=> other).to be 1 }
      end

      describe 'with a clause with a subclass value and an error' do
        let(:other_error) { Spec::Error }
        let(:other_value) { Spec::CustomValue }

        it { expect(match_clause <=> other).to be 1 }
      end

      describe 'with a clause with an unrelated value' do
        let(:other_value) { Class.new }

        it { expect(match_clause <=> other).to be 0 }
      end

      describe 'with a clause with an unrelated value and an error' do
        let(:other_error) { Spec::Error }
        let(:other_value) { Class.new }

        it { expect(match_clause <=> other).to be 1 }
      end
    end

    context 'when initialized with a value and an error' do
      let(:error) { Spec::Error }
      let(:value) { Spec::Value }

      example_class 'Spec::CustomValue', 'Spec::Value'

      describe 'with a clause' do
        it { expect(match_clause <=> other).to be(-1) }
      end

      describe 'with a clause with the same error' do
        let(:other_error) { Spec::Error }

        it { expect(match_clause <=> other).to be(-1) }
      end

      describe 'with a clause with a superclass error' do
        let(:other_error) { Cuprum::Error }

        it { expect(match_clause <=> other).to be(-1) }
      end

      describe 'with a clause with a subclass error' do
        let(:error)       { Cuprum::Error }
        let(:other_error) { Spec::Error }

        it { expect(match_clause <=> other).to be(-1) }
      end

      describe 'with a clause with an unrelated error' do
        let(:other_error) { Class.new(Cuprum::Error) }

        it { expect(match_clause <=> other).to be(-1) }
      end

      describe 'with a clause with the same value' do
        let(:other_value) { Spec::Value }

        it { expect(match_clause <=> other).to be(-1) }
      end

      describe 'with a clause with the same value and the same error' do
        let(:other_error) { Spec::Error }
        let(:other_value) { Spec::Value }

        it { expect(match_clause <=> other).to be 0 }
      end

      describe 'with a clause with the same value and a superclass error' do
        let(:other_error) { Cuprum::Error }
        let(:other_value) { Spec::Value }

        it { expect(match_clause <=> other).to be(-1) }
      end

      describe 'with a clause with the same value and a subclass error' do
        let(:error)       { Cuprum::Error }
        let(:other_error) { Spec::Error }
        let(:other_value) { Spec::Value }

        it { expect(match_clause <=> other).to be 1 }
      end

      describe 'with a clause with the same value and an unrelated error' do
        let(:other_error) { Class.new(Cuprum::Error) }
        let(:other_value) { Spec::Value }

        it { expect(match_clause <=> other).to be 0 }
      end

      describe 'with a clause with a superclass value' do
        let(:value)       { Spec::CustomValue }
        let(:other_value) { Spec::Value }

        it { expect(match_clause <=> other).to be(-1) }
      end

      describe 'with a clause with a superclass value and the same error' do
        let(:value)       { Spec::CustomValue }
        let(:other_error) { Spec::Error }
        let(:other_value) { Spec::Value }

        it { expect(match_clause <=> other).to be(-1) }
      end

      describe 'with a clause with a superclass value and a superclass error' do
        let(:value)       { Spec::CustomValue }
        let(:other_error) { Cuprum::Error }
        let(:other_value) { Spec::Value }

        it { expect(match_clause <=> other).to be(-1) }
      end

      describe 'with a clause with a superclass value and a subclass error' do
        let(:error)       { Cuprum::Error }
        let(:value)       { Spec::CustomValue }
        let(:other_error) { Spec::Error }
        let(:other_value) { Spec::Value }

        it { expect(match_clause <=> other).to be(-1) }
      end

      describe 'with a clause with a superclass value and an unrelated error' do
        let(:value)       { Spec::CustomValue }
        let(:other_error) { Class.new(Cuprum::Error) }
        let(:other_value) { Spec::Value }

        it { expect(match_clause <=> other).to be(-1) }
      end

      describe 'with a clause with a subclass value' do
        let(:other_value) { Spec::CustomValue }

        it { expect(match_clause <=> other).to be 1 }
      end

      describe 'with a clause with a subclass value and the same error' do
        let(:other_error) { Spec::Error }
        let(:other_value) { Spec::CustomValue }

        it { expect(match_clause <=> other).to be 1 }
      end

      describe 'with a clause with a subclass value and a superclass error' do
        let(:other_error) { Cuprum::Error }
        let(:other_value) { Spec::CustomValue }

        it { expect(match_clause <=> other).to be 1 }
      end

      describe 'with a clause with a subclass value and a subclass error' do
        let(:error)       { Cuprum::Error }
        let(:other_error) { Spec::Error }
        let(:other_value) { Spec::CustomValue }

        it { expect(match_clause <=> other).to be 1 }
      end

      describe 'with a clause with a subclass value and an unrelated error' do
        let(:other_error) { Class.new(Cuprum::Error) }
        let(:other_value) { Spec::CustomValue }

        it { expect(match_clause <=> other).to be 1 }
      end

      describe 'with a clause with an unrelated value' do
        let(:other_value) { Class.new }

        it { expect(match_clause <=> other).to be(-1) }
      end

      describe 'with a clause with an unrelated value and the same error' do
        let(:other_value) { Class.new }
        let(:other_error) { Spec::Error }

        it { expect(match_clause <=> other).to be 0 }
      end

      describe 'with a clause with an unrelated value and a superclass error' do
        let(:other_error) { Cuprum::Error }
        let(:other_value) { Class.new }

        it { expect(match_clause <=> other).to be(-1) }
      end

      describe 'with a clause with an unrelated value and a subclass error' do
        let(:error)       { Cuprum::Error }
        let(:other_error) { Spec::Error }
        let(:other_value) { Class.new }

        it { expect(match_clause <=> other).to be 1 }
      end

      describe 'with a clause with an unrelated value and an unrelated error' do
        let(:other_error) { Class.new(Cuprum::Error) }
        let(:other_value) { Class.new }

        it { expect(match_clause <=> other).to be 0 }
      end
    end
  end

  describe '#block' do
    include_examples 'should define reader', :block, -> { block }
  end

  describe '#error' do
    include_examples 'should define reader', :error, nil

    context 'when initialized with an error' do
      let(:error) { Cuprum::Error }

      it { expect(match_clause.error).to be error }
    end
  end

  describe '#matches_details?' do
    let(:other_error) { nil }
    let(:other_value) { nil }
    let(:matches_details) do
      match_clause.matches_details?(error: other_error, value: other_value)
    end

    example_class 'Spec::Error', Cuprum::Error

    example_class 'Spec::Value'

    it 'should define the method' do
      expect(match_clause)
        .to respond_to(:matches_details?)
        .with(0).arguments
        .and_keywords(:error, :value)
    end

    describe 'with empty details' do
      it { expect(matches_details).to be true }
    end

    describe 'with an error' do
      let(:other_error) { Spec::Error }

      it { expect(matches_details).to be false }
    end

    describe 'with a value' do
      let(:other_value) { Spec::Value }

      it { expect(matches_details).to be false }
    end

    describe 'with a value and an error' do
      let(:other_error) { Spec::Error }
      let(:other_value) { Spec::Value }

      it { expect(matches_details).to be false }
    end

    context 'when initialized with an error' do
      let(:error) { Cuprum::Error }

      describe 'with empty details' do
        it { expect(matches_details).to be false }
      end

      describe 'with the same error' do
        let(:other_error) { Cuprum::Error }

        it { expect(matches_details).to be true }
      end

      describe 'with a superclass of the error' do
        let(:error)       { Spec::Error }
        let(:other_error) { Cuprum::Error }

        it { expect(matches_details).to be false }
      end

      describe 'with a subclass of the error' do
        let(:other_error) { Spec::Error }

        it { expect(matches_details).to be true }
      end

      describe 'with an unrelated error' do
        let(:error)       { Spec::Error }
        let(:other_error) { Class.new(Cuprum::Error) }

        it { expect(matches_details).to be false }
      end

      describe 'with a value and a matching error' do
        let(:other_error) { Cuprum::Error }
        let(:other_value) { Spec::Value }

        it { expect(matches_details).to be false }
      end
    end

    context 'when initialized with a value' do
      let(:value) { Spec::Value }

      describe 'with empty details' do
        it { expect(matches_details).to be false }
      end

      describe 'with an error and a matching value' do
        let(:other_error) { Cuprum::Error }
        let(:other_value) { Spec::Value }

        it { expect(matches_details).to be false }
      end

      describe 'with the same value' do
        let(:other_value) { Spec::Value }

        it { expect(matches_details).to be true }
      end

      describe 'with a superclass of the value' do
        let(:value)       { Spec::CustomValue }
        let(:other_value) { Spec::Value }

        example_class 'Spec::CustomValue', 'Spec::Value'

        it { expect(matches_details).to be false }
      end

      describe 'with a subclass of the value' do
        let(:value)       { Spec::Value }
        let(:other_value) { Spec::CustomValue }

        example_class 'Spec::CustomValue', 'Spec::Value'

        it { expect(matches_details).to be true }
      end

      describe 'with an unrelated value' do
        let(:other_value) { Class.new }

        it { expect(matches_details).to be false }
      end
    end

    context 'when initialized with a value and an error' do
      let(:error) { Cuprum::Error }
      let(:value) { Spec::Value }

      describe 'with empty details' do
        it { expect(matches_details).to be false }
      end

      describe 'with the same error' do
        let(:other_error) { Cuprum::Error }

        it { expect(matches_details).to be false }

        describe 'with a non-matching value' do
          let(:other_value) { Class.new }

          it { expect(matches_details).to be false }
        end

        describe 'with a matching value' do
          let(:other_value) { Spec::Value }

          it { expect(matches_details).to be true }
        end
      end

      describe 'with a superclass of the error' do
        let(:error)       { Spec::Error }
        let(:other_error) { Cuprum::Error }

        it { expect(matches_details).to be false }

        describe 'with a matching value' do
          let(:other_value) { Spec::Value }

          it { expect(matches_details).to be false }
        end
      end

      describe 'with a subclass of the error' do
        let(:other_error) { Spec::Error }

        it { expect(matches_details).to be false }

        describe 'with a non-matching value' do
          let(:other_value) { Class.new }

          it { expect(matches_details).to be false }
        end

        describe 'with a matching value' do
          let(:other_value) { Spec::Value }

          it { expect(matches_details).to be true }
        end
      end

      describe 'with an unrelated error' do
        let(:error)       { Spec::Error }
        let(:other_error) { Class.new(Cuprum::Error) }

        it { expect(matches_details).to be false }

        describe 'with a matching value' do
          let(:other_value) { Spec::Value }

          it { expect(matches_details).to be false }
        end
      end

      describe 'with the same value' do
        let(:other_value) { Spec::Value }

        it { expect(matches_details).to be false }

        describe 'with a non-matching error' do
          let(:error)       { Spec::Error }
          let(:other_error) { Class.new(Cuprum::Error) }

          it { expect(matches_details).to be false }
        end

        describe 'with a matching error' do
          let(:other_error) { Cuprum::Error }

          it { expect(matches_details).to be true }
        end
      end

      describe 'with a superclass of the value' do
        let(:value)       { Spec::CustomValue }
        let(:other_value) { Spec::Value }

        example_class 'Spec::CustomValue', 'Spec::Value'

        it { expect(matches_details).to be false }

        describe 'with a matching error' do
          let(:other_error) { Cuprum::Error }

          it { expect(matches_details).to be false }
        end
      end

      describe 'with a subclass of the value' do
        let(:value)       { Spec::Value }
        let(:other_value) { Spec::CustomValue }

        example_class 'Spec::CustomValue', 'Spec::Value'

        it { expect(matches_details).to be false }

        describe 'with a non-matching error' do
          let(:error)       { Spec::Error }
          let(:other_error) { Class.new(Cuprum::Error) }

          it { expect(matches_details).to be false }
        end

        describe 'with a matching error' do
          let(:other_error) { Cuprum::Error }

          it { expect(matches_details).to be true }
        end
      end

      describe 'with an unrelated value' do
        let(:other_value) { Class.new }

        it { expect(matches_details).to be false }

        describe 'with a matching error' do
          let(:other_error) { Cuprum::Error }

          it { expect(matches_details).to be false }
        end
      end
    end
  end

  describe '#matches_result?' do
    let(:other_error) { nil }
    let(:other_value) { nil }
    let(:result) do
      Cuprum::Result.new(error: other_error, value: other_value)
    end
    let(:matches_result) do
      match_clause.matches_result?(result: result)
    end

    example_class 'Spec::Error', Cuprum::Error

    example_class 'Spec::Value'

    it 'should define the method' do
      expect(match_clause)
        .to respond_to(:matches_result?)
        .with(0).arguments
        .and_keywords(:result)
    end

    describe 'with an empty result' do
      it { expect(matches_result).to be true }
    end

    describe 'with a result with an error' do
      let(:other_error) { Cuprum::Error.new }

      it { expect(matches_result).to be true }
    end

    describe 'with a result with a value' do
      let(:other_value) { Spec::Value.new }

      it { expect(matches_result).to be true }
    end

    describe 'with a result with a value and an error' do
      let(:other_error) { Cuprum::Error.new }
      let(:other_value) { Spec::Value.new }

      it { expect(matches_result).to be true }
    end

    context 'when initialized with an error' do
      let(:error) { Cuprum::Error }

      describe 'with an empty result' do
        it { expect(matches_result).to be false }
      end

      describe 'with a result with an instance of the error' do
        let(:other_error) { Cuprum::Error.new }

        it { expect(matches_result).to be true }
      end

      describe 'with a result with an instance of a superclass of the error' do
        let(:error)       { Spec::Error }
        let(:other_error) { Cuprum::Error.new }

        it { expect(matches_result).to be false }
      end

      describe 'with a result with an instance of a subclass of the error' do
        let(:error)       { Cuprum::Error }
        let(:other_error) { Spec::Error.new }

        it { expect(matches_result).to be true }
      end

      describe 'with a result with an unrelated error' do
        let(:error)       { Spec::Error }
        let(:other_error) { Class.new(Cuprum::Error).new }

        it { expect(matches_result).to be false }
      end

      describe 'with a result with a value' do
        let(:other_value) { Spec::Value.new }

        it { expect(matches_result).to be false }
      end

      describe 'with a result with a value and a non-matching error' do
        let(:error)       { Spec::Error }
        let(:other_error) { Class.new(Cuprum::Error).new }
        let(:other_value) { Spec::Value.new }

        it { expect(matches_result).to be false }
      end

      describe 'with a result with a value and a matching error' do
        let(:other_error) { Cuprum::Error.new }
        let(:other_value) { Spec::Value.new }

        it { expect(matches_result).to be true }
      end
    end

    context 'when initialized with a value' do
      let(:value) { Spec::Value }

      describe 'with an empty result' do
        it { expect(matches_result).to be false }
      end

      describe 'with a result with an error' do
        let(:other_error) { Cuprum::Error.new }

        it { expect(matches_result).to be false }
      end

      describe 'with a result with an error and a non-matching value' do
        let(:other_error) { Cuprum::Error.new }
        let(:other_value) { Object.new.freeze }

        it { expect(matches_result).to be false }
      end

      describe 'with a result with an error and a matching value' do
        let(:other_error) { Cuprum::Error.new }
        let(:other_value) { Spec::Value.new }

        it { expect(matches_result).to be true }
      end

      describe 'with a result with an instance of the value' do
        let(:other_value) { Spec::Value.new }

        it { expect(matches_result).to be true }
      end

      describe 'with a result with an instance of a superclass of the value' do
        let(:value)       { Spec::CustomValue }
        let(:other_value) { Spec::Value.new }

        example_class 'Spec::CustomValue', 'Spec::Value'

        it { expect(matches_result).to be false }
      end

      describe 'with a result with an instance of a subclass of the value' do
        let(:value)       { Spec::Value }
        let(:other_value) { Spec::CustomValue.new }

        example_class 'Spec::CustomValue', 'Spec::Value'

        it { expect(matches_result).to be true }
      end

      describe 'with a result with an unrelated value' do
        let(:value)       { Spec::Value }
        let(:other_value) { Object.new.freeze }

        it { expect(matches_result).to be false }
      end
    end

    context 'when initialized with a value and an error' do
      let(:error) { Cuprum::Error }
      let(:value) { Spec::Value }

      describe 'with an empty result' do
        it { expect(matches_result).to be false }
      end

      describe 'with a result with an instance of the error' do
        let(:other_error) { Cuprum::Error.new }

        it { expect(matches_result).to be false }

        context 'when the result has a non-matching value' do
          let(:other_value) { Object.new.freeze }

          it { expect(matches_result).to be false }
        end

        context 'when the result has a matching value' do
          let(:other_value) { Spec::Value.new }

          it { expect(matches_result).to be true }
        end
      end

      describe 'with a result with an instance of a superclass of the error' do
        let(:error)       { Spec::Error }
        let(:other_error) { Cuprum::Error.new }

        it { expect(matches_result).to be false }

        context 'when the result has a matching value' do
          let(:other_value) { Spec::Value.new }

          it { expect(matches_result).to be false }
        end
      end

      describe 'with a result with an instance of a subclass of the error' do
        let(:error)       { Cuprum::Error }
        let(:other_error) { Spec::Error.new }

        it { expect(matches_result).to be false }

        context 'when the result has a non-matching value' do
          let(:other_value) { Object.new.freeze }

          it { expect(matches_result).to be false }
        end

        context 'when the result has a matching value' do
          let(:other_value) { Spec::Value.new }

          it { expect(matches_result).to be true }
        end
      end

      describe 'with a result with an unrelated error' do
        let(:error)       { Spec::Error }
        let(:other_error) { Class.new(Cuprum::Error).new }

        it { expect(matches_result).to be false }

        context 'when the result has a matching value' do
          let(:other_value) { Spec::Value.new }

          it { expect(matches_result).to be false }
        end
      end

      describe 'with a result with an instance of the value' do
        let(:other_value) { Spec::Value.new }

        it { expect(matches_result).to be false }

        context 'when the result has a non-matching error' do
          let(:error)       { Spec::Error }
          let(:other_error) { Class.new(Cuprum::Error).new }

          it { expect(matches_result).to be false }
        end

        context 'when the result has a matching error' do
          let(:other_error) { Cuprum::Error.new }

          it { expect(matches_result).to be true }
        end
      end

      describe 'with a result with an instance of a superclass of the value' do
        let(:value)       { Spec::CustomValue }
        let(:other_value) { Spec::Value.new }

        example_class 'Spec::CustomValue', 'Spec::Value'

        it { expect(matches_result).to be false }

        context 'when the result has a matching error' do
          let(:other_error) { Cuprum::Error.new }

          it { expect(matches_result).to be false }
        end
      end

      describe 'with a result with an instance of a subclass of the value' do
        let(:value)       { Spec::Value }
        let(:other_value) { Spec::CustomValue.new }

        example_class 'Spec::CustomValue', 'Spec::Value'

        it { expect(matches_result).to be false }

        context 'when the result has a non-matching error' do
          let(:error)       { Spec::Error }
          let(:other_error) { Class.new(Cuprum::Error).new }

          it { expect(matches_result).to be false }
        end

        context 'when the result has a matching error' do
          let(:other_error) { Cuprum::Error.new }

          it { expect(matches_result).to be true }
        end
      end

      describe 'with a result with an unrelated value' do
        let(:value)       { Spec::Value }
        let(:other_value) { Object.new.freeze }

        it { expect(matches_result).to be false }

        context 'when the result has a matching error' do
          let(:other_error) { Cuprum::Error.new }

          it { expect(matches_result).to be false }
        end
      end
    end
  end

  describe '#status' do
    include_examples 'should define reader', :status, -> { status }
  end

  describe '#value' do
    include_examples 'should define reader', :value, nil

    context 'when initialized with a value' do
      let(:value) { :ok }

      it { expect(match_clause.value).to be == value }
    end
  end
end
