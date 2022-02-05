# frozen_string_literal: true

require 'cuprum/map_command'

RSpec.describe Cuprum::MapCommand do
  subject(:command) { described_class.new(**constructor_options) }

  let(:constructor_options) { {} }
  let(:implementation)      { nil }

  describe '.new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:allow_partial)
    end
  end

  describe '#allow_partial?' do
    include_examples 'should define predicate', :allow_partial?, false

    context 'when initialized with allow_partial: false' do
      let(:constructor_options) { super().merge(allow_partial: false) }

      it { expect(command.allow_partial?).to be false }
    end

    context 'when initialized with allow_partial: true' do
      let(:constructor_options) { super().merge(allow_partial: true) }

      it { expect(command.allow_partial?).to be true }
    end
  end

  describe '#call' do
    shared_context 'with an implementation that yields one argument' do
      let(:implementation_error) do
        Cuprum::Error.new(message: "String can't be blank")
      end
      let(:implementation) do
        err = implementation_error

        lambda do |string|
          return failure(err) if string.nil? || string.empty?

          string.upcase
        end
      end
    end

    shared_context 'with an implementation that yields two arguments' do
      let(:implementation_error) do
        Cuprum::Error.new(message: 'Key must be a String')
      end
      let(:implementation) do
        err = implementation_error

        lambda do |key, value|
          return failure(err) unless key.is_a?(String)

          "#{key}: #{value}"
        end
      end
    end

    shared_examples 'should map an Array' do
      describe 'with an empty Array' do
        include_context 'with an implementation that yields one argument'

        it 'should not yield control' do
          expect do |block|
            described_class.new(**constructor_options, &block).call([])
          end
            .not_to yield_control
        end

        it { expect(command.call([])).to be_a Cuprum::ResultList }

        it { expect(command.call([]).status).to be :success }

        it { expect(command.call([]).error).to be nil }

        it { expect(command.call([]).value).to be == [] }
      end

      describe 'with an Array with non-matching items' do
        include_context 'with an implementation that yields one argument'

        let(:items) { [nil, '', nil] }
        let(:expected_error) do
          Cuprum::Errors::MultipleErrors.new(
            errors: items.map { implementation_error }
          )
        end
        let(:expected_value) { Array.new(3) }

        it 'should yield each item' do
          expect do |block|
            described_class.new(**constructor_options, &block).call(items)
          end
            .to yield_successive_args(*items)
        end

        it { expect(command.call(items)).to be_a Cuprum::ResultList }

        it { expect(command.call(items).status).to be :failure }

        it { expect(command.call(items).error).to be == expected_error }

        it { expect(command.call(items).value).to be == expected_value }
      end

      describe 'with an Array with mixed non-matching and matching items' do
        include_context 'with an implementation that yields one argument'

        let(:items) do
          [
            nil,
            'Greetings, starfighter!',
            ''
          ]
        end
        let(:expected_error) do
          Cuprum::Errors::MultipleErrors.new(
            errors: [implementation_error, nil, implementation_error]
          )
        end
        let(:expected_value) do
          [nil, items[1].upcase, nil]
        end

        it 'should yield each item' do
          expect do |block|
            described_class.new(**constructor_options, &block).call(items)
          end
            .to yield_successive_args(*items)
        end

        it { expect(command.call(items)).to be_a Cuprum::ResultList }

        it { expect(command.call(items).status).to be :failure }

        it { expect(command.call(items).error).to be == expected_error }

        it { expect(command.call(items).value).to be == expected_value }
      end

      describe 'with an Array with matching items' do
        include_context 'with an implementation that yields one argument'

        let(:items) do
          [
            'Greetings, programs!',
            'Greetings, starfighter!',
            'Hello, world.'
          ]
        end
        let(:expected_value) { items.map(&:upcase) }

        it 'should yield each item' do
          expect do |block|
            described_class.new(**constructor_options, &block).call(items)
          end
            .to yield_successive_args(*items)
        end

        it { expect(command.call(items)).to be_a Cuprum::ResultList }

        it { expect(command.call(items).status).to be :success }

        it { expect(command.call(items).error).to be nil }

        it { expect(command.call(items).value).to be == expected_value }
      end

      context 'when initialized with allow_partial: true' do
        let(:constructor_options) { super().merge(allow_partial: true) }

        describe 'with an Array with mixed non-matching and matching items' do
          include_context 'with an implementation that yields one argument'

          let(:items) do
            [
              nil,
              'Greetings, starfighter!',
              ''
            ]
          end
          let(:expected_error) do
            Cuprum::Errors::MultipleErrors.new(
              errors: [implementation_error, nil, implementation_error]
            )
          end
          let(:expected_value) do
            [nil, items[1].upcase, nil]
          end

          it 'should yield each item' do
            expect do |block|
              described_class.new(**constructor_options, &block).call(items)
            end
              .to yield_successive_args(*items)
          end

          it { expect(command.call(items)).to be_a Cuprum::ResultList }

          it { expect(command.call(items).status).to be :success }

          it { expect(command.call(items).error).to be == expected_error }

          it { expect(command.call(items).value).to be == expected_value }
        end
      end
    end

    shared_examples 'should map a Hash' do
      describe 'with an empty Array' do
        include_context 'with an implementation that yields two arguments'

        it 'should not yield control' do
          expect do |block|
            described_class.new(**constructor_options, &block).call({})
          end
            .not_to yield_control
        end

        it { expect(command.call({})).to be_a Cuprum::ResultList }

        it { expect(command.call({}).status).to be :success }

        it { expect(command.call({}).error).to be nil }

        it { expect(command.call({}).value).to be == [] }
      end

      describe 'with a Hash with non-matching items' do
        include_context 'with an implementation that yields two arguments'

        let(:items) do
          {
            ichi: 1,
            ni:   2,
            san:  3
          }
        end
        let(:expected_error) do
          Cuprum::Errors::MultipleErrors.new(
            errors: items.map { implementation_error }
          )
        end
        let(:expected_value) { Array.new(3) }

        it 'should yield each key and value' do
          expect do |block|
            described_class.new(**constructor_options, &block).call(items)
          end
            .to yield_successive_args(*items)
        end

        it { expect(command.call(items)).to be_a Cuprum::ResultList }

        it { expect(command.call(items).status).to be :failure }

        it { expect(command.call(items).error).to be == expected_error }

        it { expect(command.call(items).value).to be == expected_value }
      end

      describe 'with a Hash with mixed non-matching and matching items' do
        include_context 'with an implementation that yields two arguments'

        let(:items) do
          {
            'ichi' => 1,
            ni:       2,
            'san'  => 3
          }
        end
        let(:expected_error) do
          Cuprum::Errors::MultipleErrors.new(
            errors: [nil, implementation_error, nil]
          )
        end
        let(:expected_value) do
          [
            'ichi: 1',
            nil,
            'san: 3'
          ]
        end

        it 'should yield each key and value' do
          expect do |block|
            described_class.new(**constructor_options, &block).call(items)
          end
            .to yield_successive_args(*items)
        end

        it { expect(command.call(items)).to be_a Cuprum::ResultList }

        it { expect(command.call(items).status).to be :failure }

        it { expect(command.call(items).error).to be == expected_error }

        it { expect(command.call(items).value).to be == expected_value }
      end

      describe 'with a Hash with matching items' do
        include_context 'with an implementation that yields two arguments'

        let(:items) do
          {
            'ichi' => 1,
            'ni'   => 2,
            'san'  => 3
          }
        end
        let(:expected_value) do
          [
            'ichi: 1',
            'ni: 2',
            'san: 3'
          ]
        end

        it 'should yield each key and value' do
          expect do |block|
            described_class.new(**constructor_options, &block).call(items)
          end
            .to yield_successive_args(*items)
        end

        it { expect(command.call(items)).to be_a Cuprum::ResultList }

        it { expect(command.call(items).status).to be :success }

        it { expect(command.call(items).error).to be nil }

        it { expect(command.call(items).value).to be == expected_value }
      end

      context 'when initialized with allow_partial: true' do
        let(:constructor_options) { super().merge(allow_partial: true) }

        describe 'with a Hash with mixed non-matching and matching items' do
          include_context 'with an implementation that yields two arguments'

          let(:items) do
            {
              'ichi' => 1,
              ni:       2,
              'san'  => 3
            }
          end
          let(:expected_error) do
            Cuprum::Errors::MultipleErrors.new(
              errors: [nil, implementation_error, nil]
            )
          end
          let(:expected_value) do
            [
              'ichi: 1',
              nil,
              'san: 3'
            ]
          end

          it 'should yield each key and value' do
            expect do |block|
              described_class.new(**constructor_options, &block).call(items)
            end
              .to yield_successive_args(*items)
          end

          it { expect(command.call(items)).to be_a Cuprum::ResultList }

          it { expect(command.call(items).status).to be :success }

          it { expect(command.call(items).error).to be == expected_error }

          it { expect(command.call(items).value).to be == expected_value }
        end
      end
    end

    shared_examples 'should map an Enumerable' do
      describe 'with an empty Enumerable' do
        include_context 'with an implementation that yields one argument'

        it 'should not yield control' do
          expect do |block|
            described_class.new(**constructor_options, &block).call([].each)
          end
            .not_to yield_control
        end

        it { expect(command.call([].each)).to be_a Cuprum::ResultList }

        it { expect(command.call([].each).status).to be :success }

        it { expect(command.call([].each).error).to be nil }

        it { expect(command.call([].each).value).to be == [] }
      end

      describe 'with an Enumerable with non-matching items' do
        include_context 'with an implementation that yields one argument'

        let(:items) { [nil, '', nil] }
        let(:enum)  { items.each }
        let(:expected_error) do
          Cuprum::Errors::MultipleErrors.new(
            errors: items.map { implementation_error }
          )
        end
        let(:expected_value) { Array.new(3) }

        it 'should yield each item' do
          expect do |block|
            described_class.new(**constructor_options, &block).call(enum)
          end
            .to yield_successive_args(*items)
        end

        it { expect(command.call(enum)).to be_a Cuprum::ResultList }

        it { expect(command.call(enum).status).to be :failure }

        it { expect(command.call(enum).error).to be == expected_error }

        it { expect(command.call(enum).value).to be == expected_value }
      end

      describe 'with an Enumerable with mixed non- and matching items' do
        include_context 'with an implementation that yields one argument'

        let(:items) do
          [
            nil,
            'Greetings, starfighter!',
            ''
          ]
        end
        let(:enum) { items.each }
        let(:expected_error) do
          Cuprum::Errors::MultipleErrors.new(
            errors: [implementation_error, nil, implementation_error]
          )
        end
        let(:expected_value) do
          [nil, items[1].upcase, nil]
        end

        it 'should yield each item' do
          expect do |block|
            described_class.new(**constructor_options, &block).call(enum)
          end
            .to yield_successive_args(*items)
        end

        it { expect(command.call(enum)).to be_a Cuprum::ResultList }

        it { expect(command.call(enum).status).to be :failure }

        it { expect(command.call(enum).error).to be == expected_error }

        it { expect(command.call(enum).value).to be == expected_value }
      end

      describe 'with an Enumerable with matching items' do
        include_context 'with an implementation that yields one argument'

        let(:items) do
          [
            'Greetings, programs!',
            'Greetings, starfighter!',
            'Hello, world.'
          ]
        end
        let(:enum)           { items.each }
        let(:expected_value) { items.map(&:upcase) }

        it 'should yield each item' do
          expect do |block|
            described_class.new(**constructor_options, &block).call(enum)
          end
            .to yield_successive_args(*items)
        end

        it { expect(command.call(enum)).to be_a Cuprum::ResultList }

        it { expect(command.call(enum).status).to be :success }

        it { expect(command.call(enum).error).to be nil }

        it { expect(command.call(enum).value).to be == expected_value }
      end

      context 'when initialized with allow_partial: true' do
        let(:constructor_options) { super().merge(allow_partial: true) }

        describe 'with an Enumerable with mixed non- and matching items' do
          include_context 'with an implementation that yields one argument'

          let(:items) do
            [
              nil,
              'Greetings, starfighter!',
              ''
            ]
          end
          let(:enum) { items.each }
          let(:expected_error) do
            Cuprum::Errors::MultipleErrors.new(
              errors: [implementation_error, nil, implementation_error]
            )
          end
          let(:expected_value) do
            [nil, items[1].upcase, nil]
          end

          it 'should yield each item' do
            expect do |block|
              described_class.new(**constructor_options, &block).call(enum)
            end
              .to yield_successive_args(*items)
          end

          it { expect(command.call(enum)).to be_a Cuprum::ResultList }

          it { expect(command.call(enum).status).to be :success }

          it { expect(command.call(enum).error).to be == expected_error }

          it { expect(command.call(enum).value).to be == expected_value }
        end
      end
    end

    it { expect(command).to respond_to(:call).with(1).argument }

    describe 'with an empty Array' do
      it { expect(command.call([])).to be_a Cuprum::ResultList }

      it { expect(command.call([]).status).to be :success }

      it { expect(command.call([]).error).to be nil }

      it { expect(command.call([]).value).to be == [] }
    end

    describe 'with an empty Hash' do
      it { expect(command.call({})).to be_a Cuprum::ResultList }

      it { expect(command.call({}).status).to be :success }

      it { expect(command.call({}).error).to be nil }

      it { expect(command.call({}).value).to be == [] }
    end

    describe 'with an empty Enumerator' do
      it { expect(command.call([].each)).to be_a Cuprum::ResultList }

      it { expect(command.call([].each).status).to be :success }

      it { expect(command.call([].each).error).to be nil }

      it { expect(command.call([].each).value).to be == [] }
    end

    describe 'with a non-empty Enumerable' do
      let(:enumerable) { %w[ichi ni san].each }
      let(:expected_error) do
        Cuprum::Errors::MultipleErrors.new(
          errors: Array.new(3) do
            Cuprum::Errors::CommandNotImplemented.new(command: command)
          end
        )
      end

      it { expect(command.call(enumerable)).to be_a Cuprum::ResultList }

      it { expect(command.call(enumerable).status).to be :failure }

      it { expect(command.call(enumerable).error).to be == expected_error }

      it { expect(command.call([].each).value).to be == [] }
    end

    context 'when initialized with an implementation' do
      subject(:command) do
        described_class.new(**constructor_options, &implementation)
      end

      include_examples 'should map an Array'

      include_examples 'should map a Hash'

      include_examples 'should map an Enumerable'
    end

    context 'with a command subclass' do
      let(:described_class) { Spec::ExampleMapCommand }

      example_class 'Spec::ExampleMapCommand', Cuprum::MapCommand do |klass| # rubocop:disable RSpec/DescribedClass
        klass.define_method(:process, &implementation)
      end

      include_examples 'should map an Array'

      include_examples 'should map a Hash'

      include_examples 'should map an Enumerable'
    end

    context 'when a custom result object is returned' do
      include_context 'with an implementation that yields one argument'

      let(:described_class) { Spec::ExampleMapCommand }

      example_class 'Spec::ExampleMapCommand', Cuprum::MapCommand do |klass| # rubocop:disable RSpec/DescribedClass
        klass.define_method(:process, &implementation)

        klass.define_method(:build_result_list) do |results|
          Cuprum::ResultList.new(*results, value: 'custom value')
        end
      end

      describe 'with an empty Array' do
        include_context 'with an implementation that yields one argument'

        it { expect(command.call([])).to be_a Cuprum::ResultList }

        it { expect(command.call([]).value).to be == 'custom value' }
      end

      describe 'with an Array with matching items' do
        include_context 'with an implementation that yields one argument'

        let(:items) do
          [
            'Greetings, programs!',
            'Greetings, starfighter!',
            'Hello, world.'
          ]
        end

        it { expect(command.call(items)).to be_a Cuprum::ResultList }

        it { expect(command.call(items).value).to be == 'custom value' }
      end
    end
  end
end
