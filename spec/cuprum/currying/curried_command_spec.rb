# frozen_string_literal: true

require 'cuprum/currying/curried_command'

RSpec.describe Cuprum::Currying::CurriedCommand do
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

  shared_context 'when initialized with many arguments and keywords' do
    include_context 'when initialized with many arguments'
    include_context 'when initialized with many keywords'
  end

  subject(:instance) do
    described_class.new(
      arguments: arguments,
      command:   command,
      keywords:  keywords
    )
  end

  let(:command)   { Cuprum::Command.new }
  let(:arguments) { [] }
  let(:keywords)  { {} }

  describe '::new' do
    it 'should define the constructor' do
      expect(described_class)
        .to be_constructible
        .with(0).arguments
        .and_keywords(:arguments, :command, :keywords)
    end
  end

  describe '#arguments' do
    include_examples 'should have reader', :arguments, -> { arguments }

    wrap_context 'when initialized with one argument' do
      it { expect(instance.arguments).to be == arguments }
    end

    wrap_context 'when initialized with many arguments' do
      it { expect(instance.arguments).to be == arguments }
    end

    wrap_context 'when initialized with many arguments and keywords' do
      it { expect(instance.arguments).to be == arguments }
    end
  end

  describe '#call' do
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

      it 'should call the command with the expected parameters' do
        call_curried_command

        expect(command).to have_received(:call).with(*expected_parameters)
      end

      it 'should return the result' do
        expect(call_curried_command).to be result
      end

      it 'should yield the block to the command' do
        allow(command).to receive(:call) { |&block| block.call }

        expect { |block| call_curried_command(&block) }.to yield_control
      end
    end

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

      describe 'with many arguments and keywords' do
        let(:args)   { %w[uno dos tres] }
        let(:kwargs) { { daito: 'medium', shoto: 'short', tachi: 'long' } }

        include_examples 'should call the command with the expected parameters'
      end
    end

    let(:args)   { [] }
    let(:kwargs) { {} }
    let(:result) { Cuprum::Result.new }

    before(:example) { allow(command).to receive(:call).and_return(result) }

    def call_curried_command(&block) # rubocop:disable Metrics/AbcSize
      if block_given? && kwargs.empty?
        instance.call(*args, &block)
      elsif block_given?
        instance.call(*args, **kwargs, &block)
      elsif kwargs.empty?
        instance.call(*args)
      else
        instance.call(*args, **kwargs)
      end
    end

    it { expect(instance).to respond_to(:call).with_unlimited_arguments }

    include_examples 'should curry the arguments and keywords'

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

    wrap_context 'when initialized with many arguments and keywords' do
      include_examples 'should curry the arguments and keywords'

      describe 'with a matching keyword' do
        let(:kwargs) { { foo: 'FOO' } }

        include_examples 'should call the command with the expected parameters'
      end
    end
  end

  describe '#command' do
    include_examples 'should have reader', :command, -> { command }
  end

  describe '#keywords' do
    include_examples 'should have reader', :keywords, -> { keywords }

    wrap_context 'when initialized with one keyword' do
      it { expect(instance.keywords).to be == keywords }
    end

    wrap_context 'when initialized with many keywords' do
      it { expect(instance.keywords).to be == keywords }
    end

    wrap_context 'when initialized with many arguments and keywords' do
      it { expect(instance.keywords).to be == keywords }
    end
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
