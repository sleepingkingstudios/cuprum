# frozen_string_literal: true

require 'cuprum/currying/curried_command'
require 'cuprum/rspec/be_a_result'

RSpec.describe Cuprum::Currying::CurriedCommand do
  include Cuprum::RSpec::Matchers

  shared_context 'when initialized with one argument' do
    let(:arguments) { %i[ichi] }
  end

  shared_context 'when initialized with many arguments' do
    let(:arguments) { %i[ichi ni san] }
  end

  shared_context 'when initialized with one keyword' do
    let(:keywords) { { foo: 'foo' } }
  end

  shared_context 'when initialized with many keywords' do
    let(:keywords) { { foo: 'foo', bar: 'bar', baz: 'baz' } }
  end

  shared_context 'when initialized with a block' do
    let(:block) { -> {} }
  end

  shared_context 'when initialized with many arguments and keywords' do
    include_context 'when initialized with many arguments'
    include_context 'when initialized with many keywords'
  end

  shared_context 'when initialized with arguments, keywords, and a block' do
    include_context 'when initialized with many arguments'
    include_context 'when initialized with many keywords'
    include_context 'when initialized with a block'
  end

  subject(:instance) do
    described_class.new(
      arguments: arguments,
      block:     block,
      command:   command,
      keywords:  keywords
    )
  end

  let(:block)     { nil }
  let(:command)   { Cuprum::Command.new }
  let(:arguments) { [] }
  let(:keywords)  { {} }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:arguments, :block, :command, :keywords)
    end
  end

  describe '#arguments' do
    include_examples 'should have reader', :arguments, -> { arguments }

    # rubocop:disable RSpec/RepeatedExampleGroupBody
    wrap_context 'when initialized with one argument' do
      it { expect(instance.arguments).to be == arguments }
    end

    wrap_context 'when initialized with many arguments' do
      it { expect(instance.arguments).to be == arguments }
    end

    wrap_context 'when initialized with many arguments and keywords' do
      it { expect(instance.arguments).to be == arguments }
    end

    wrap_context 'when initialized with arguments, keywords, and a block' do
      it { expect(instance.arguments).to be == arguments }
    end
    # rubocop:enable RSpec/RepeatedExampleGroupBody
  end

  describe '#block' do
    include_examples 'should have reader', :block, nil

    # rubocop:disable RSpec/RepeatedExampleGroupBody
    wrap_context 'when initialized with a block' do
      it { expect(instance.block).to be == block }
    end

    wrap_context 'when initialized with arguments, keywords, and a block' do
      it { expect(instance.block).to be == block }
    end
    # rubocop:enable RSpec/RepeatedExampleGroupBody
  end

  describe '#call' do
    # rubocop:disable RSpec/MultipleMemoizedHelpers
    shared_examples 'should call the command with the expected parameters' do
      let(:expected_arguments) do
        [*arguments, *args]
      end
      let(:expected_keywords) do
        keywords.merge(kwargs)
      end
      let(:expected_parameters) do
        params =
          if expected_keywords.empty?
            expected_arguments
          else
            [*expected_arguments, expected_keywords]
          end

        params.empty? ? no_args : params
      end
      let(:expected_block) { blk || block }

      it 'should call the command with the expected parameters' do
        call_curried_command

        expect(command).to have_received(:call).with(*expected_parameters)
      end

      it 'should call the command with the expected block' do
        expect(call_curried_command)
          .to be_a_passing_result
          .with_value(expected_block)
      end

      it 'should return the result' do
        allow(command).to receive(:call).and_return(result)

        expect(call_curried_command).to be result
      end
    end
    # rubocop:enable RSpec/MultipleMemoizedHelpers

    shared_examples 'should curry the arguments and keywords' do
      describe 'with no arguments' do
        include_examples 'should call the command with the expected parameters'
      end

      describe 'with one argument' do
        let(:args) { %w[uno] }

        include_examples 'should call the command with the expected parameters'
      end

      describe 'with many arguments' do
        let(:args) { %w[uno dos tres] }

        include_examples 'should call the command with the expected parameters'
      end

      describe 'with one keyword' do
        let(:kwargs) { { key: 'value' } }

        include_examples 'should call the command with the expected parameters'
      end

      describe 'with many keywords' do
        let(:kwargs) { { daito: 'medium', shoto: 'short', tachi: 'long' } }

        include_examples 'should call the command with the expected parameters'
      end

      describe 'with a block' do
        let(:blk) { -> {} }

        include_examples 'should call the command with the expected parameters'
      end

      describe 'with many arguments and keywords' do
        let(:args)   { %w[uno dos tres] }
        let(:kwargs) { { daito: 'medium', shoto: 'short', tachi: 'long' } }

        include_examples 'should call the command with the expected parameters'
      end

      describe 'with arguments, keywords, and a block' do
        let(:args)   { %w[uno dos tres] }
        let(:kwargs) { { daito: 'medium', shoto: 'short', tachi: 'long' } }
        let(:blk)    { -> {} }

        include_examples 'should call the command with the expected parameters'
      end
    end

    let(:command) { Cuprum::Command.new { |*_, **_, &block| block } }
    let(:args)    { [] }
    let(:kwargs)  { {} }
    let(:blk)     { nil }
    let(:result)  { Cuprum::Result.new }

    def call_curried_command
      if kwargs.empty?
        instance.call(*args, &blk)
      else
        instance.call(*args, **kwargs, &blk)
      end
    end

    before(:example) { allow(command).to receive(:call).and_call_original }

    it { expect(instance).to respond_to(:call).with_unlimited_arguments }

    include_examples 'should curry the arguments and keywords'

    # rubocop:disable RSpec/RepeatedExampleGroupBody
    wrap_context 'when initialized with one argument' do
      include_examples 'should curry the arguments and keywords'
    end

    wrap_context 'when initialized with many arguments' do
      include_examples 'should curry the arguments and keywords'
    end

    wrap_context 'when initialized with one keyword' do
      include_examples 'should curry the arguments and keywords'

      describe 'with a matching keyword' do
        let(:kwargs) { { foo: 'FOO' } }

        include_examples 'should call the command with the expected parameters'
      end
    end

    wrap_context 'when initialized with many keywords' do
      include_examples 'should curry the arguments and keywords'

      describe 'with a matching keyword' do
        let(:kwargs) { { foo: 'FOO' } }

        include_examples 'should call the command with the expected parameters'
      end
    end

    wrap_context 'when initialized with a block' do
      include_examples 'should curry the arguments and keywords'
    end

    wrap_context 'when initialized with many arguments and keywords' do
      include_examples 'should curry the arguments and keywords'

      describe 'with a matching keyword' do
        let(:kwargs) { { foo: 'FOO' } }

        include_examples 'should call the command with the expected parameters'
      end
    end

    wrap_context 'when initialized with arguments, keywords, and a block' do
      include_examples 'should curry the arguments and keywords'
    end
    # rubocop:enable RSpec/RepeatedExampleGroupBody
  end

  describe '#command' do
    include_examples 'should have reader', :command, -> { command }
  end

  describe '#keywords' do
    include_examples 'should have reader', :keywords, -> { keywords }

    # rubocop:disable RSpec/RepeatedExampleGroupBody
    wrap_context 'when initialized with one keyword' do
      it { expect(instance.keywords).to be == keywords }
    end

    wrap_context 'when initialized with many keywords' do
      it { expect(instance.keywords).to be == keywords }
    end

    wrap_context 'when initialized with many arguments and keywords' do
      it { expect(instance.keywords).to be == keywords }
    end

    wrap_context 'when initialized with arguments, keywords, and a block' do
      it { expect(instance.keywords).to be == keywords }
    end
    # rubocop:enable RSpec/RepeatedExampleGroupBody
  end

  describe '#process' do
    it 'should define the method' do
      expect(instance)
        .to respond_to(:process, true)
        .with_unlimited_arguments
        .and_any_keywords
        .and_a_block
    end
  end
end
