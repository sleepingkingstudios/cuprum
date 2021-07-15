# frozen_string_literal: true

require 'cuprum/middleware'
require 'cuprum/rspec/be_a_result'

RSpec.describe Cuprum::Middleware do
  include Cuprum::RSpec::Matchers

  subject(:middleware) { described_class.new }

  describe '.apply' do
    let(:command) do
      Cuprum::Command.new { |ary| ary << 'command' }
    end
    let(:middleware) { [] }
    let(:applied_middleware) do
      described_class.apply(command: command, middleware: middleware)
    end

    example_class 'Spec::ExampleMiddleware', Cuprum::Command \
    do |klass|
      klass.include Cuprum::Middleware # rubocop:disable RSpec/DescribedClass

      klass.send :define_method, :initialize do |**options|
        super()

        @options = options
      end

      klass.send :attr_reader, :options

      klass.send :define_method, :process do |cmd, ary|
        ary << ['before', options[:index]].compact.join('_')

        ary = cmd.call(ary).value

        ary << ['after', options[:index]].compact.join('_')
      end

      klass.send :private, :process
    end

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:apply)
        .with(0).arguments
        .and_keywords(:command, :middleware)
    end

    describe 'with a middleware command' do
      let(:middleware) { Spec::ExampleMiddleware.new }
      let(:expected)   { %w[before command after] }

      it 'should return a curried command' do
        expect(applied_middleware).to be_a Cuprum::Currying::CurriedCommand
      end

      it 'should call the command and the middleware' do
        result = applied_middleware.call([])

        expect(result.value).to be == expected
      end
    end

    describe 'with an empty middleware array' do
      let(:expected) { %w[command] }

      it 'should return the command' do
        expect(applied_middleware).to be command
      end

      it 'should call the command' do
        result = applied_middleware.call([])

        expect(result.value).to be == expected
      end
    end

    describe 'with a middleware array with one item' do
      let(:middleware) do
        [
          Spec::ExampleMiddleware.new
        ]
      end
      let(:expected) { %w[before command after] }

      it 'should return a curried command' do
        expect(applied_middleware).to be_a Cuprum::Currying::CurriedCommand
      end

      it 'should call the command and the middleware' do
        result = applied_middleware.call([])

        expect(result.value).to be == expected
      end
    end

    describe 'with a middleware array with many items' do
      let(:middleware) do
        [
          Spec::ExampleMiddleware.new(index: 1),
          Spec::ExampleMiddleware.new(index: 2),
          Spec::ExampleMiddleware.new(index: 3)
        ]
      end
      let(:expected) do
        %w[before_1 before_2 before_3 command after_3 after_2 after_1]
      end

      it 'should return a curried command' do
        expect(applied_middleware).to be_a Cuprum::Currying::CurriedCommand
      end

      it 'should call the command and the middleware' do
        result = applied_middleware.call([])

        expect(result.value).to be == expected
      end
    end
  end

  describe '#call' do
    shared_context 'when the middleware is partially applied' do
      let(:curried) { middleware.curry(next_command) }

      def call_command(*args, &block)
        curried.call(*args, &block)
      end
    end

    shared_context 'with a basic middleware implementation' do
      let(:data)      { { key: 'value' } }
      let(:arguments) { [data] }
      let(:expected)  { data.merge(inner: true) }

      before(:example) do
        allow(next_command).to receive(:call) do |hsh|
          Cuprum::Result.new(status: next_status, value: hsh.merge(inner: true))
        end
      end
    end

    shared_examples 'should call the next command' do
      it 'should call the next command' do
        call_command

        expect(next_command).to have_received(:call).with(no_args)
      end

      describe 'with arguments' do
        let(:arguments) { %w[uno dos tres] }

        it 'should call the next command' do
          call_command(*arguments)

          expect(next_command).to have_received(:call).with(*arguments)
        end
      end

      describe 'with keywords' do
        let(:keywords) { { ichi: 1, ni: 2, san: 3 } }

        it 'should call the next command' do
          call_command(**keywords)

          expect(next_command).to have_received(:call).with(**keywords)
        end
      end

      describe 'with a block' do
        let(:block) { -> {} }

        before(:example) do
          allow(next_command).to receive(:call) { |*_, **_, &block| block }
        end

        it 'should call the next command' do
          call_command(&block)

          expect(next_command).to have_received(:call).with(no_args)
        end

        it 'should pass the block to the next command' do
          expect(call_command(&block)).to be_a_passing_result.with_value(block)
        end
      end

      describe 'with arguments and keywords' do
        let(:arguments) { %w[uno dos tres] }
        let(:keywords)  { { ichi: 1, ni: 2, san: 3 } }

        it 'should call the next command' do
          call_command(*arguments, **keywords)

          expect(next_command)
            .to have_received(:call)
            .with(*arguments, **keywords)
        end
      end

      describe 'with arguments, keywords, and a block' do
        let(:arguments) { %w[uno dos tres] }
        let(:keywords)  { { ichi: 1, ni: 2, san: 3 } }
        let(:block)     { -> {} }

        before(:example) do
          allow(next_command).to receive(:call) { |*_, **_, &block| block }
        end

        it 'should call the next command' do
          call_command(*arguments, **keywords, &block)

          expect(next_command)
            .to have_received(:call)
            .with(*arguments, **keywords)
        end

        it 'should pass the block to the next command' do
          expect(call_command(*arguments, **keywords, &block))
            .to be_a_passing_result
            .with_value(block)
        end
      end
    end

    let(:described_class) { Spec::Middleware }
    let(:next_status)     { :success }
    let(:next_command)    { instance_double(Cuprum::Command, call: nil) }
    let(:arguments)       { [] }
    let(:keywords)        { {} }

    def call_command(*args, **kwargs, &block)
      if kwargs.empty?
        middleware.call(next_command, *args, &block)
      else
        middleware.call(next_command, *args, **kwargs, &block)
      end
    end

    example_class 'Spec::Middleware', Cuprum::Command do |klass|
      klass.include Cuprum::Middleware # rubocop:disable RSpec/DescribedClass
    end

    it { expect(middleware).to respond_to(:call).with(2).arguments }

    include_examples 'should call the next command'

    context 'when the next_command returns a failing result' do
      include_context 'with a basic middleware implementation'

      let(:next_status) { :failure }

      it 'should return the result of the next command' do
        expect(call_command(data).to_cuprum_result)
          .to be_a_failing_result
          .with_value(expected)
      end
    end

    context 'when the next command returns a passing result' do
      include_context 'with a basic middleware implementation'

      let(:next_status) { :success }

      it 'should return the result of the next command' do
        expect(call_command(data).to_cuprum_result)
          .to be_a_passing_result
          .with_value(expected)
      end
    end

    wrap_context 'when the middleware is partially applied' do
      include_examples 'should call the next command'

      context 'when the next command returns a passing result' do
        include_context 'with a basic middleware implementation'

        let(:next_status) { :success }

        it 'should return the result of the next command' do
          expect(call_command(data).to_cuprum_result)
            .to be_a_passing_result
            .with_value(expected)
        end
      end

      context 'when the next_command returns a failing result' do
        include_context 'with a basic middleware implementation'

        let(:next_status) { :failure }

        it 'should return the result of the next command' do
          expect(call_command(data).to_cuprum_result)
            .to be_a_failing_result
            .with_value(expected)
        end
      end
    end

    context 'with a middleware implementation' do
      include_context 'with a basic middleware implementation'

      before(:example) do
        described_class.define_method(:process) do |next_command, data|
          data = data.merge(before: true)

          data = super(next_command, data)

          data.merge(after: true)
        end
      end

      it 'should call the next command' do
        call_command(data)

        expect(next_command)
          .to have_received(:call)
          .with(data.merge(before: true))
      end

      context 'when the next_command returns a failing result' do
        let(:next_status) { :failure }
        let(:expected)    { super().merge(before: true) }

        it 'should return the result of the next command' do
          expect(call_command(data).to_cuprum_result)
            .to be_a_failing_result
            .with_value(expected)
        end
      end

      context 'when the next_command returns a passing result' do
        let(:next_status) { :success }
        let(:expected)    { super().merge(before: true, after: true) }

        it 'should return the result of the next command' do
          expect(call_command(data).to_cuprum_result)
            .to be_a_passing_result
            .with_value(expected)
        end
      end
    end
  end
end
