# frozen_string_literal: true

require 'cuprum/utils/parameters_mapping'

RSpec.describe Cuprum::Utils::ParametersMapping do
  subject(:mapping) { described_class.new(**constructor_options) }

  deferred_context 'when initialized with arguments' do
    let(:arguments) { %w[article author] }
    let(:constructor_options) do
      super().merge(arguments:)
    end
  end

  deferred_context 'when initialized with a block' do
    let(:block) { :action }
    let(:constructor_options) do
      super().merge(block:)
    end
  end

  deferred_context 'when initialized with keywords' do
    let(:keywords) { %w[publisher publication_date] }
    let(:constructor_options) do
      super().merge(keywords:)
    end
  end

  deferred_context 'when initialized with variadic arguments' do
    let(:variadic_arguments) { 'tags' }
    let(:constructor_options) do
      super().merge(variadic_arguments:)
    end
  end

  deferred_context 'when initialized with variadic keywords' do
    let(:variadic_keywords) { 'options' }
    let(:constructor_options) do
      super().merge(variadic_keywords:)
    end
  end

  let(:constructor_options) { {} }

  describe '.new' do
    let(:expected_keywords) do
      %i[
        arguments
        block
        keywords
        variadic_arguments
        variadic_keywords
      ]
    end

    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(*expected_keywords)
    end
  end

  describe '.build' do
    deferred_examples 'should define the mapping' \
    do |
      arguments:          [],
      block:              nil,
      keywords:           [],
      variadic_arguments: nil,
      variadic_keywords:  nil
    |
      it { expect(mapping.arguments).to be == arguments }

      it { expect(mapping.block).to be block }

      it { expect(mapping.keywords).to match_array(keywords) }

      it { expect(mapping.variadic_arguments).to be variadic_arguments }

      it { expect(mapping.variadic_keywords).to be variadic_keywords }
    end

    let(:callable) { -> {} }
    let(:mapping)  { described_class.build(callable) }

    it { expect(described_class).to respond_to(:build).with(1).argument }

    it { expect(mapping).to be_a described_class }

    include_deferred 'should define the mapping'

    # rubocop:disable Lint/UnusedBlockArgument
    describe 'with a callable with optional arguments' do
      let(:callable) { ->(author = nil, other = nil) {} }

      include_deferred 'should define the mapping',
        arguments: %i[author other]
    end

    describe 'with a callable with required arguments' do
      let(:callable) { ->(article, other) {} }

      include_deferred 'should define the mapping',
        arguments: %i[article other]
    end

    describe 'with a callable with required and optional arguments' do
      let(:callable) { ->(article, author = nil, other = nil) {} }

      include_deferred 'should define the mapping',
        arguments: %i[article author other]
    end

    describe 'with a callable with variadic arguments' do
      let(:callable) { ->(*tags) {} }

      include_deferred 'should define the mapping',
        variadic_arguments: :tags
    end

    describe 'with a callable with optional keywords' do
      let(:callable) { ->(other: nil, publication_date: nil) {} }

      include_deferred 'should define the mapping',
        keywords: %i[other publication_date]
    end

    describe 'with a callable with required keywords' do
      let(:callable) { ->(other:, publisher:) {} }

      include_deferred 'should define the mapping',
        keywords: %i[other publisher]
    end

    describe 'with a callable with required and optional keywords' do
      let(:callable) { ->(publisher:, other: nil, publication_date: nil) {} }

      include_deferred 'should define the mapping',
        keywords: %i[other publication_date publisher]
    end

    describe 'with a callable with variadic keywords' do
      let(:callable) { ->(**options) {} }

      include_deferred 'should define the mapping',
        variadic_keywords: :options
    end

    describe 'with a callable with a block parameter' do
      let(:callable) { ->(&action) {} }

      include_deferred 'should define the mapping',
        block: :action
    end

    describe 'with a callable with mixed parameters' do
      let(:callable) do
        # rubocop:disable Style/NilLambda
        lambda do |
          article,
          author = nil,
          *tags,
          publisher:,
          publication_date: nil,
          **options,
          &action
        |
          # :nocov:
          nil
          # :nocov:
        end
        # rubocop:enable Style/NilLambda
      end

      include_deferred 'should define the mapping',
        arguments:          %i[article author],
        keywords:           %i[publisher publication_date],
        variadic_arguments: :tags,
        variadic_keywords:  :options,
        block:              :action
    end

    describe 'with a callable with an unnamed argument' do
      let(:callable) { :itself.to_proc }

      include_deferred 'should define the mapping'
    end
    # rubocop:enable Lint/UnusedBlockArgument
  end

  describe '#arguments' do
    include_examples 'should define reader', :arguments, []

    context 'when initialized with arguments: an Array of Strings' do
      let(:arguments) { %w[article author] }
      let(:expected)  { %i[article author] }
      let(:constructor_options) do
        super().merge(arguments:)
      end

      it { expect(mapping.arguments).to be == expected }
    end

    context 'when initialized with arguments: an Array of Symbols' do
      let(:arguments) { %i[article author] }
      let(:constructor_options) do
        super().merge(arguments:)
      end

      it { expect(mapping.arguments).to be == arguments }
    end
  end

  describe '#arguments_count' do
    include_examples 'should define reader', :arguments_count, 0

    wrap_deferred 'when initialized with arguments' do
      it { expect(mapping.arguments_count).to be 2 }
    end
  end

  describe '#block' do
    include_examples 'should define reader', :block, nil

    wrap_deferred 'when initialized with a block' do
      it { expect(mapping.block).to be block }
    end
  end

  describe '#block?' do
    include_examples 'should define predicate', :block?, false

    wrap_deferred 'when initialized with a block' do
      it { expect(mapping.block?).to be true }
    end
  end

  describe '#call' do
    it 'should define the method' do
      expect(mapping)
        .to respond_to(:call)
        .with_unlimited_arguments
        .and_any_keywords
        .and_a_block
    end

    describe 'with no parameters' do
      let(:expected) { {} }

      it { expect(mapping.call).to be == expected }
    end

    describe 'with extra parameters' do
      let(:expected) { {} }

      it { expect(mapping.call(:extra, key: :extra, &-> {})).to be == expected }
    end

    wrap_deferred 'when initialized with a block' do
      describe 'with no parameters' do
        let(:expected) { { action: nil } }

        it { expect(mapping.call).to be == expected }
      end

      describe 'with matching parameters' do
        let(:block_arg) { -> {} }
        let(:expected)  { { action: block_arg } }

        it { expect(mapping.call(&block_arg)).to be == expected }
      end
    end

    wrap_deferred 'when initialized with arguments' do
      describe 'with no parameters' do
        let(:expected) do
          {
            article: nil,
            author:  nil
          }
        end

        it { expect(mapping.call).to be == expected }
      end

      describe 'with matching parameters' do
        let(:args) { ['Intermediate Bones', 'Doctor Skelebone'] }
        let(:expected) do
          {
            article: 'Intermediate Bones',
            author:  'Doctor Skelebone'
          }
        end

        it { expect(mapping.call(*args)).to be == expected }
      end

      describe 'with extra parameters' do
        let(:args) { ['Intermediate Bones', 'Doctor Skelebone', :extra] }
        let(:expected) do
          {
            article: 'Intermediate Bones',
            author:  'Doctor Skelebone'
          }
        end

        it { expect(mapping.call(*args)).to be == expected }
      end
    end

    wrap_deferred 'when initialized with keywords' do
      describe 'with no parameters' do
        let(:expected) do
          {
            publisher:        nil,
            publication_date: nil
          }
        end

        it { expect(mapping.call).to be == expected }
      end

      describe 'with matching parameters' do
        let(:kwargs) do
          {
            publisher:        'The First House',
            publication_date: '2019-09-10'
          }
        end
        let(:expected) do
          {
            publisher:        'The First House',
            publication_date: '2019-09-10'
          }
        end

        it { expect(mapping.call(**kwargs)).to be == expected }
      end

      describe 'with extra parameters' do
        let(:kwargs) do
          {
            publisher:        'The First House',
            publication_date: '2019-09-10',
            extra:            :value
          }
        end
        let(:expected) do
          {
            publisher:        'The First House',
            publication_date: '2019-09-10'
          }
        end

        it { expect(mapping.call(**kwargs)).to be == expected }
      end
    end

    wrap_deferred 'when initialized with variadic arguments' do
      describe 'with no parameters' do
        let(:expected) { { tags: [] } }

        it { expect(mapping.call).to be == expected }
      end

      describe 'with matching parameters' do
        let(:args)     { %w[bones necromancy] }
        let(:expected) { { tags: %w[bones necromancy] } }

        it { expect(mapping.call(*args)).to be == expected }
      end
    end

    wrap_deferred 'when initialized with variadic keywords' do
      describe 'with no parameters' do
        let(:expected) { { options: {} } }

        it { expect(mapping.call).to be == expected }
      end

      describe 'with matching parameters' do
        let(:kwargs)   { { harrowing: true, spooky: true } }
        let(:expected) { { options: { harrowing: true, spooky: true } } }

        it { expect(mapping.call(**kwargs)).to be == expected }
      end
    end

    context 'when initialized with mixed parameters' do
      include_deferred 'when initialized with a block'
      include_deferred 'when initialized with arguments'
      include_deferred 'when initialized with keywords'
      include_deferred 'when initialized with variadic arguments'
      include_deferred 'when initialized with variadic keywords'

      describe 'with no parameters' do
        let(:expected) do
          {
            action:           nil,
            article:          nil,
            author:           nil,
            options:          {},
            publication_date: nil,
            publisher:        nil,
            tags:             []
          }
        end

        it { expect(mapping.call).to be == expected }
      end

      describe 'with matching parameters' do
        let(:args) do
          [
            'Intermediate Bones',
            'Doctor Skelebone',
            'bones',
            'necromancy'
          ]
        end
        let(:kwargs) do
          {
            harrowing:        true,
            publisher:        'The First House',
            publication_date: '2019-09-10',
            spooky:           true
          }
        end
        let(:block_arg) { -> {} }
        let(:expected) do
          {
            action:           block_arg,
            article:          'Intermediate Bones',
            author:           'Doctor Skelebone',
            options:          { harrowing: true, spooky: true },
            publication_date: '2019-09-10',
            publisher:        'The First House',
            tags:             %w[bones necromancy]
          }
        end

        it 'should map the parameters' do
          expect(mapping.call(*args, **kwargs, &block_arg)).to be == expected
        end
      end
    end
  end

  describe '#keywords' do
    include_examples 'should define reader', :keywords

    it { expect(mapping.keywords).to be_a Set }

    it { expect(mapping.keywords.empty?).to be true }

    context 'when initialized with keywords: an Array of Strings' do
      let(:keywords) { %w[publisher publication_date] }
      let(:expected) { keywords.map(&:to_sym) }
      let(:constructor_options) do
        super().merge(keywords:)
      end

      it { expect(mapping.keywords).to match_array(expected) }
    end

    context 'when initialized with keywords: an Array of Symbols' do
      let(:keywords) { %i[publisher publication_date] }
      let(:constructor_options) do
        super().merge(keywords:)
      end

      it { expect(mapping.keywords).to match_array(keywords) }
    end
  end

  describe '#variadic_arguments' do
    include_examples 'should define reader', :variadic_arguments, nil

    context 'when initialized with variadic_arguments: a String' do
      let(:variadic_arguments) { 'tags' }
      let(:constructor_options) do
        super().merge(variadic_arguments:)
      end

      it { expect(mapping.variadic_arguments).to be :tags }
    end

    context 'when initialized with variadic_arguments: a Symbol' do
      let(:variadic_arguments) { :tags }
      let(:constructor_options) do
        super().merge(variadic_arguments:)
      end

      it { expect(mapping.variadic_arguments).to be :tags }
    end
  end

  describe '#variadic_arguments?' do
    include_examples 'should define predicate', :variadic_arguments?, false

    wrap_deferred 'when initialized with variadic arguments' do
      it { expect(mapping.variadic_arguments?).to be true }
    end
  end

  describe '#variadic_keywords' do
    include_examples 'should define reader', :variadic_keywords, nil

    context 'when initialized with variadic_keywords: a String' do
      let(:variadic_keywords) { 'options' }
      let(:constructor_options) do
        super().merge(variadic_keywords:)
      end

      it { expect(mapping.variadic_keywords).to be :options }
    end

    context 'when initialized with variadic_keywords: a Symbol' do
      let(:variadic_keywords) { :options }
      let(:constructor_options) do
        super().merge(variadic_keywords:)
      end

      it { expect(mapping.variadic_keywords).to be :options }
    end
  end

  describe '#variadic_keywords?' do
    include_examples 'should define predicate', :variadic_keywords?, false

    wrap_deferred 'when initialized with variadic keywords' do
      it { expect(mapping.variadic_keywords?).to be true }
    end
  end
end
