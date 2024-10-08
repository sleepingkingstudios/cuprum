# frozen_string_literal: true

require 'cuprum/command'

require 'support/examples/currying_examples'
require 'support/examples/processing_examples'
require 'support/examples/result_helpers_examples'
require 'support/examples/steps_examples'

RSpec.describe Cuprum::Command do
  include Spec::Examples::CurryingExamples
  include Spec::Examples::ProcessingExamples
  include Spec::Examples::ResultHelpersExamples
  include Spec::Examples::StepsExamples

  subject(:command) { described_class.new }

  let(:implementation) { -> {} }
  let(:result_class)   { Cuprum::Result }

  describe '::new' do
    it { expect(described_class).to be_constructible.with(0).arguments }
  end

  include_examples 'should implement the Currying interface'

  include_examples 'should implement the Currying methods'

  include_examples 'should implement the Processing interface'

  include_examples 'should implement the Processing methods'

  include_examples 'should implement the ResultHelpers interface'

  include_examples 'should implement the ResultHelpers methods'

  include_examples 'should implement the Steps interface'

  include_examples 'should implement the Steps methods'

  # rubocop:disable RSpec/MultipleMemoizedHelpers
  describe '.subclass' do
    subject(:command) { subclass.new(*arguments, **keywords, &block) }

    let(:described_class)    { Spec::ExampleCommand }
    let(:subclass_arguments) { [] }
    let(:subclass_keywords)  { {} }
    let(:subclass_block)     { nil }
    let(:subclass) do
      described_class.subclass(
        *subclass_arguments,
        **subclass_keywords,
        &subclass_block
      )
    end
    let(:arguments)          { [] }
    let(:keywords)           { {} }
    let(:block)              { nil }
    let(:expected_arguments) { subclass_arguments + arguments }
    let(:expected_keywords)  { subclass_keywords.merge(keywords) }
    let(:expected_block)     { block || subclass_block }

    example_class 'Spec::ExampleCommand', Cuprum::Command do |klass| # rubocop:disable RSpec/DescribedClass
      klass.define_method(:initialize) do |*arguments, **keywords, &block|
        super()

        @arguments = arguments
        @block     = block
        @keywords  = keywords
      end

      klass.attr_reader :arguments

      klass.attr_reader :block

      klass.attr_reader :keywords
    end

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:subclass)
        .with(0).arguments
        .and_unlimited_arguments
        .and_any_keywords
        .and_a_block
    end

    it { expect(subclass).to be_a Class }

    it { expect(subclass).to be < described_class }

    it { expect(command.arguments).to be == expected_arguments }

    it { expect(command.block).to be == expected_block }

    it { expect(command.keywords).to be == expected_keywords }

    context 'when the command is initialized with parameters' do
      let(:arguments) { %w[yon go roku] }
      let(:keywords)  { { quantity: 10_000, purpose: '???' } }
      let(:block)     { -> { { ok: true } } }

      it { expect(command.arguments).to be == expected_arguments }

      it { expect(command.block).to be == expected_block }

      it { expect(command.keywords).to be == expected_keywords }
    end

    describe 'with parameters' do
      let(:subclass_arguments) { %w[ichi ni san] }
      let(:subclass_keywords)  { { name: 'Stem Bolt', quantity: 0 } }
      let(:subclass_block)     { -> { { ok: false } } }

      it { expect(command.arguments).to be == expected_arguments }

      it { expect(command.block).to be == expected_block }

      it { expect(command.keywords).to be == expected_keywords }

      context 'when the command is initialized with parameters' do
        let(:arguments) { %w[yon go roku] }
        let(:keywords)  { { quantity: 10_000, purpose: '???' } }
        let(:block)     { -> { { ok: true } } }

        it { expect(command.arguments).to be == expected_arguments }

        it { expect(command.block).to be == expected_block }

        it { expect(command.keywords).to be == expected_keywords }
      end
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers

  describe '#call' do
    let(:implementation) { -> {} }

    context 'when the command is initialized with a block' do
      shared_context 'when the implementation is defined' do
        subject(:command) { described_class.new(&implementation) }
      end

      include_examples 'should execute the command implementation'

      wrap_context 'when the implementation is defined' do
        context 'when the implementation throws :cuprum_failed_step'

        let(:result) { Cuprum::Result.new(status: :failure) }
        let(:implementation) do
          thrown = result

          -> { throw :cuprum_failed_step, thrown }
        end

        it 'should return the thrown result' do
          expect(command.call).to be result
        end
      end
    end

    context 'when the #process method is defined' do
      shared_context 'when the implementation is defined' do
        let(:described_class) do
          process = implementation

          Class.new(super()) do |klass|
            klass.send(:define_method, :process, &process)
          end
        end
      end

      include_examples 'should execute the command implementation'

      wrap_context 'when the implementation is defined' do
        context 'when the implementation throws :cuprum_failed_step'

        let(:result) { Cuprum::Result.new(status: :failure) }
        let(:implementation) do
          thrown = result

          -> { throw :cuprum_failed_step, thrown }
        end

        it 'should return the thrown result' do
          expect(command.call).to be result
        end
      end
    end
  end

  describe '#to_proc' do
    let(:proc)   { command.to_proc }
    let(:result) { proc.call }
    let(:expected_error) do
      Cuprum::Errors::CommandNotImplemented.new(command:)
    end

    it { expect(command).to respond_to(:to_proc).with(0).arguments }

    it { expect(command.to_proc).to be_a Proc }

    it { expect(command.to_proc).to be proc }

    it { expect(result).to be_a(Cuprum::Result) }

    it { expect(result.success?).to be false }

    it { expect(result.error).to be == expected_error }

    it { expect(nil.then(&command)).to be_a(Cuprum::Result) }

    it 'should call the command with arguments' do
      # rubocop:disable RSpec/SubjectStub
      arguments = %w[ichi ni san]

      allow(command).to receive(:call)

      proc.call(*arguments)

      expect(command).to have_received(:call).with(*arguments)
      # rubocop:enable RSpec/SubjectStub
    end

    it 'should call the command with keywords' do
      # rubocop:disable RSpec/SubjectStub
      keywords = { ichi: 1, ni: 2, san: 3 }

      allow(command).to receive(:call)

      proc.call(**keywords)

      expect(command).to have_received(:call).with(**keywords)
      # rubocop:enable RSpec/SubjectStub
    end

    context 'when the implementation is defined' do
      let(:described_class) do
        process = implementation

        Class.new(super()) do |klass|
          klass.send(:define_method, :process, &process)
        end
      end
      let(:implementation) { lambda(&:upcase) }
      let(:value)          { 'Greetings, programs!' }
      let(:result)         { proc.call(value) }
      let(:expected_value) { value.upcase }

      it { expect(result).to be_a(Cuprum::Result) }

      it { expect(result.success?).to be true }

      it { expect(result.value).to be == expected_value }

      it { expect(value.then(&command).value).to be == expected_value }
    end

    context 'when the command is defined with another command' do
      subject(:command) { described_class.new(&inner_command) }

      let(:inner_command)  { Cuprum::Command.new } # rubocop:disable RSpec/DescribedClass
      let(:implementation) { inner_command.to_proc }

      before(:example) do
        allow(inner_command).to receive(:call)
      end

      it 'should call the inner command' do
        command.call('ichi', ni: 2)

        expect(inner_command).to have_received(:call).with('ichi', ni: 2)
      end
    end
  end
end
