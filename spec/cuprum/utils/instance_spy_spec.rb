require 'cuprum/utils/instance_spy'

RSpec.describe Cuprum::Utils::InstanceSpy do
  shared_context 'when there is an instance spy on a function class' do
    let(:function_class) do
      defined?(super()) ? super() : Spec::ExampleFunction
    end # let
    let(:instance_spy) { described_class.spy_on(function_class) }

    before(:example) do
      allow(instance_spy).to receive(:call)
    end # before example
  end # shared_context

  options = { :base_class => Cuprum::Command }
  example_class 'Spec::ExampleFunction', options do |klass|
    klass.send :define_method, :process do |*_args|
      'returned_value'.freeze
    end # define_method
  end # example_class

  options = { :base_class => Cuprum::Operation }
  example_class 'Spec::ExampleOperation', options do |klass|
    klass.send :define_method, :process do |*_args|
      'returned_value'.freeze
    end # define_method
  end # example_class

  describe '::clear_spies' do
    it { expect(described_class).to respond_to(:clear_spies).with(0).arguments }

    it { expect(described_class.clear_spies).to be nil }

    wrap_context 'when there is an instance spy on a function class' do
      let(:function_instance) { function_class.new }

      it { expect(described_class.clear_spies).to be nil }

      it 'should clear the instance spy' do
        described_class.clear_spies

        function_instance.call

        expect(instance_spy).not_to have_received(:call)
      end # it

      it 'should not clear instance spies in other threads' do
        Thread.new { described_class.clear_spies }.join

        function_instance.call

        expect(instance_spy).to have_received(:call)
      end # it
    end # context
  end # describe

  describe '::spy_on' do
    let(:function_arguments) do
      ['ichi', 'ni', 'san', { 'yon' => 4, 'go' => 5 }]
    end # let

    after(:example) { described_class.clear_spies }

    it { expect(described_class).to respond_to(:spy_on).with(1).argument }

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.spy_on nil }.to raise_error ArgumentError
      end # it
    end # describe

    describe 'with a class' do
      it 'should raise an error' do
        expect { described_class.spy_on Object }.to raise_error ArgumentError
      end # it
    end # describe

    describe 'with a function instance' do
      let(:function_class) { Spec::ExampleFunction.new }

      it 'should raise an error' do
        expect { described_class.spy_on function_class }.
          to raise_error ArgumentError
      end # it
    end # describe

    describe 'with a function class' do
      let(:function_class)    { Spec::ExampleFunction }
      let(:function_instance) { function_class.new }

      it 'should return a spy' do
        spy = described_class.spy_on(function_class)

        expect(spy).to be_a described_class::Spy
      end # it

      it 'should instrument calls to #call' do
        spy = described_class.spy_on(function_class)

        allow(spy).to receive(:call)

        function_instance.call(*function_arguments)

        expect(spy).to have_received(:call).with(*function_arguments)
      end # it

      it 'should execute the function implementation' do
        allow(function_instance).to receive(:process)

        described_class.spy_on(function_class)

        function_instance.call(*function_arguments)

        expect(function_instance).
          to have_received(:process).
          with(*function_arguments)
      end # it

      wrap_context 'when there is an instance spy on a function class' do
        it 'should return the existing spy' do
          expect(described_class.spy_on(function_class)).to be instance_spy
        end # it
      end # wrap_context
    end # describe

    describe 'with a function class and a block' do
      let(:function_class)    { Spec::ExampleFunction }
      let(:function_instance) { function_class.new }

      it { expect(described_class.spy_on(function_class) {}).to be nil }

      it 'should yield a spy' do
        block_called = false

        described_class.spy_on(function_class) do |spy|
          block_called = true

          expect(spy).to be_a described_class::Spy
        end # spy_on

        expect(block_called).to be true
      end # it

      it 'should instrument calls to #call' do
        described_class.spy_on(function_class) do |spy|
          allow(spy).to receive(:call)

          function_instance.call(*function_arguments)

          expect(spy).to have_received(:call).with(*function_arguments)
        end # spy_on
      end # it

      it 'should execute the function implementation' do
        allow(function_instance).to receive(:process)

        described_class.spy_on(function_class) do
          function_instance.call(*function_arguments)
        end # spy_on

        expect(function_instance).
          to have_received(:process).
          with(*function_arguments)
      end # it

      wrap_context 'when there is an instance spy on a function class' do
        it { expect(described_class.spy_on(function_class) {}).to be nil }

        it 'should yield the existing spy' do
          block_called = false

          described_class.spy_on(function_class) do |spy|
            block_called = true

            expect(spy).to be instance_spy
          end # spy_on

          expect(block_called).to be true
        end # it
      end # wrap_context
    end # describe

    describe 'with Cuprum::Command' do
      let(:function_class)    { Spec::ExampleFunction }
      let(:function_instance) { function_class.new }

      it 'should return a spy' do
        spy = described_class.spy_on(Cuprum::Command)

        expect(spy).to be_a described_class::Spy
      end # it

      it 'should instrument calls to #call on a subclass' do
        spy = described_class.spy_on(Cuprum::Command)

        allow(spy).to receive(:call)

        function_instance.call(*function_arguments)

        expect(spy).to have_received(:call).with(*function_arguments)
      end # it
    end # describe

    describe 'with an operation class' do
      let(:function_class)    { Spec::ExampleOperation }
      let(:function_instance) { function_class.new }

      it 'should return a spy' do
        spy = described_class.spy_on(function_class)

        expect(spy).to be_a described_class::Spy
      end # it

      it 'should instrument calls to #call' do
        spy = described_class.spy_on(function_class)

        allow(spy).to receive(:call)

        function_instance.call(*function_arguments)

        expect(spy).to have_received(:call).with(*function_arguments)
      end # it

      it 'should execute the function implementation' do
        allow(function_instance).to receive(:process)

        described_class.spy_on(function_class)

        function_instance.call(*function_arguments)

        expect(function_instance).
          to have_received(:process).
          with(*function_arguments)
      end # it

      wrap_context 'when there is an instance spy on a function class' do
        it 'should return the existing spy' do
          expect(described_class.spy_on(function_class)).to be instance_spy
        end # it
      end # wrap_context
    end # describe

    describe 'with an operation class and a block' do
      let(:function_class)    { Spec::ExampleOperation }
      let(:function_instance) { function_class.new }

      it { expect(described_class.spy_on(function_class) {}).to be nil }

      it 'should yield a spy' do
        block_called = false

        described_class.spy_on(function_class) do |spy|
          block_called = true

          expect(spy).to be_a described_class::Spy
        end # spy_on

        expect(block_called).to be true
      end # it

      it 'should instrument calls to #call' do
        described_class.spy_on(function_class) do |spy|
          allow(spy).to receive(:call)

          function_instance.call(*function_arguments)

          expect(spy).to have_received(:call).with(*function_arguments)
        end # spy_on
      end # it

      it 'should execute the function implementation' do
        allow(function_instance).to receive(:process)

        described_class.spy_on(function_class) do
          function_instance.call(*function_arguments)
        end # spy_on

        expect(function_instance).
          to have_received(:process).
          with(*function_arguments)
      end # it

      wrap_context 'when there is an instance spy on a function class' do
        it { expect(described_class.spy_on(function_class) {}).to be nil }

        it 'should yield the existing spy' do
          block_called = false

          described_class.spy_on(function_class) do |spy|
            block_called = true

            expect(spy).to be instance_spy
          end # spy_on

          expect(block_called).to be true
        end # it
      end # wrap_context
    end # describe

    describe 'with Cuprum::Operation' do
      let(:function_class)    { Spec::ExampleOperation }
      let(:function_instance) { function_class.new }

      it 'should return a spy' do
        spy = described_class.spy_on(Cuprum::Operation)

        expect(spy).to be_a described_class::Spy
      end # it

      it 'should instrument calls to #call on a subclass' do
        spy = described_class.spy_on(Cuprum::Operation)

        allow(spy).to receive(:call)

        function_instance.call(*function_arguments)

        expect(spy).to have_received(:call).with(*function_arguments)
      end # it
    end # describe

    describe 'with a module' do
      let(:function_class)    { Spec::ExampleOperation }
      let(:function_instance) { function_class.new }

      it 'should return a spy' do
        spy = described_class.spy_on(Cuprum::Operation::Mixin)

        expect(spy).to be_a described_class::Spy
      end # it

      it 'should instrument calls to #call' do
        spy = described_class.spy_on(Cuprum::Operation::Mixin)

        allow(spy).to receive(:call)

        function_instance.call(*function_arguments)

        expect(spy).to have_received(:call).with(*function_arguments)
      end # it

      it 'should execute the function implementation' do
        allow(function_instance).to receive(:process)

        described_class.spy_on(Cuprum::Operation::Mixin)

        function_instance.call(*function_arguments)

        expect(function_instance).
          to have_received(:process).
          with(*function_arguments)
      end # it
    end # describe

    wrap_context 'when there is an instance spy on a function class' do
      describe 'with a function subclass' do
        let(:function_subclass) { Class.new(function_class) }
        let(:function_instance) { function_subclass.new }

        it 'should return a spy' do
          spy = described_class.spy_on(function_subclass)

          expect(spy).to be_a described_class::Spy
          expect(spy).not_to be instance_spy
        end # it

        it 'should instrument calls to #call on the subclass' do
          spy = described_class.spy_on(function_subclass)

          allow(instance_spy).to receive(:call)
          allow(spy).to receive(:call)

          function_instance.call(*function_arguments)

          expect(instance_spy).to have_received(:call).with(*function_arguments)
          expect(spy).to have_received(:call).with(*function_arguments)
        end # it

        it 'should not instrument calls in other threads' do
          allow(instance_spy).to receive(:call)

          Thread.new { function_instance.call(*function_arguments) }.join

          expect(instance_spy).not_to have_received(:call)
        end # it
      end # describe
    end # wrap_context
  end # describe
end # describe
