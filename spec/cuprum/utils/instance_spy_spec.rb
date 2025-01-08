# frozen_string_literal: true

require 'cuprum/command'
require 'cuprum/operation'
require 'cuprum/utils/instance_spy'

RSpec.describe Cuprum::Utils::InstanceSpy do
  shared_context 'when there is an instance spy on a command class' do
    let(:command_class) do
      defined?(super()) ? super() : Spec::ExampleCommand
    end
    let(:instance_spy) { described_class.spy_on(command_class) }

    before(:example) do
      allow(instance_spy).to receive(:call)
    end
  end

  example_class 'Spec::ExampleCommand', base_class: Cuprum::Operation \
  do |klass|
    klass.send :define_method, :process do |*_args|
      'returned_value'
    end
  end

  example_class 'Spec::ExampleOperation', base_class: Cuprum::Operation \
  do |klass|
    klass.send :define_method, :process do |*_args|
      'returned_value'
    end
  end

  describe '::clear_spies' do
    it { expect(described_class).to respond_to(:clear_spies).with(0).arguments }

    it { expect(described_class.clear_spies).to be nil }

    wrap_context 'when there is an instance spy on a command class' do
      let(:command_instance) { command_class.new }

      it { expect(described_class.clear_spies).to be nil }

      it 'should clear the instance spy' do
        described_class.clear_spies

        command_instance.call

        expect(instance_spy).not_to have_received(:call)
      end

      it 'should not clear instance spies in other threads' do
        Thread.new { described_class.clear_spies }.join

        command_instance.call

        expect(instance_spy).to have_received(:call)
      end
    end
  end

  describe '::spy_on' do
    let(:command_arguments) do
      ['ichi', 'ni', 'san', { 'yon' => 4, 'go' => 5 }]
    end

    after(:example) { described_class.clear_spies }

    it { expect(described_class).to respond_to(:spy_on).with(1).argument }

    describe 'with nil' do
      it 'should raise an error' do
        expect { described_class.spy_on nil }.to raise_error ArgumentError
      end
    end

    describe 'with a class' do
      it 'should raise an error' do
        expect { described_class.spy_on Object }.to raise_error ArgumentError
      end
    end

    describe 'with a command instance' do
      let(:command_class) { Spec::ExampleCommand.new }

      it 'should raise an error' do
        expect { described_class.spy_on command_class }
          .to raise_error ArgumentError
      end
    end

    describe 'with a command class' do
      let(:command_class)    { Spec::ExampleCommand }
      let(:command_instance) { command_class.new }

      it 'should return a spy' do
        spy = described_class.spy_on(command_class)

        expect(spy).to be_a described_class::Spy
      end

      it 'should instrument calls to #call' do
        spy = described_class.spy_on(command_class)

        allow(spy).to receive(:call)

        command_instance.call(*command_arguments)

        expect(spy).to have_received(:call).with(*command_arguments)
      end

      it 'should execute the command implementation' do
        allow(command_instance).to receive(:process)

        described_class.spy_on(command_class)

        command_instance.call(*command_arguments)

        expect(command_instance)
          .to have_received(:process)
          .with(*command_arguments)
      end

      wrap_context 'when there is an instance spy on a command class' do
        it 'should return the existing spy' do
          expect(described_class.spy_on(command_class)).to be instance_spy
        end
      end
    end

    describe 'with a command class and a block' do
      let(:command_class)    { Spec::ExampleCommand }
      let(:command_instance) { command_class.new }

      it { expect(described_class.spy_on(command_class) { nil }).to be nil }

      it 'should yield a spy', :aggregate_failures do
        block_called = false

        described_class.spy_on(command_class) do |spy|
          block_called = true

          expect(spy).to be_a described_class::Spy
        end

        expect(block_called).to be true
      end

      it 'should instrument calls to #call' do
        described_class.spy_on(command_class) do |spy|
          allow(spy).to receive(:call)

          command_instance.call(*command_arguments)

          expect(spy).to have_received(:call).with(*command_arguments)
        end
      end

      it 'should execute the command implementation' do
        allow(command_instance).to receive(:process)

        described_class.spy_on(command_class) do
          command_instance.call(*command_arguments)
        end

        expect(command_instance)
          .to have_received(:process)
          .with(*command_arguments)
      end

      wrap_context 'when there is an instance spy on a command class' do
        it { expect(described_class.spy_on(command_class) { nil }).to be nil }

        it 'should yield the existing spy', :aggregate_failures do
          block_called = false

          described_class.spy_on(command_class) do |spy|
            block_called = true

            expect(spy).to be instance_spy
          end

          expect(block_called).to be true
        end
      end
    end

    describe 'with Cuprum::Command' do
      let(:command_class)    { Spec::ExampleCommand }
      let(:command_instance) { command_class.new }

      it 'should return a spy' do
        spy = described_class.spy_on(Cuprum::Command)

        expect(spy).to be_a described_class::Spy
      end

      it 'should instrument calls to #call on a subclass' do
        spy = described_class.spy_on(Cuprum::Command)

        allow(spy).to receive(:call)

        command_instance.call(*command_arguments)

        expect(spy).to have_received(:call).with(*command_arguments)
      end
    end

    describe 'with an operation class' do
      let(:command_class)    { Spec::ExampleOperation }
      let(:command_instance) { command_class.new }

      it 'should return a spy' do
        spy = described_class.spy_on(command_class)

        expect(spy).to be_a described_class::Spy
      end

      it 'should instrument calls to #call' do
        spy = described_class.spy_on(command_class)

        allow(spy).to receive(:call)

        command_instance.call(*command_arguments)

        expect(spy).to have_received(:call).with(*command_arguments)
      end

      it 'should execute the command implementation' do
        allow(command_instance).to receive(:process)

        described_class.spy_on(command_class)

        command_instance.call(*command_arguments)

        expect(command_instance)
          .to have_received(:process)
          .with(*command_arguments)
      end

      wrap_context 'when there is an instance spy on a command class' do
        it 'should return the existing spy' do
          expect(described_class.spy_on(command_class)).to be instance_spy
        end
      end
    end

    describe 'with an operation class and a block' do
      let(:command_class)    { Spec::ExampleOperation }
      let(:command_instance) { command_class.new }

      it { expect(described_class.spy_on(command_class) { nil }).to be nil }

      it 'should yield a spy', :aggregate_failures do
        block_called = false

        described_class.spy_on(command_class) do |spy|
          block_called = true

          expect(spy).to be_a described_class::Spy
        end

        expect(block_called).to be true
      end

      it 'should instrument calls to #call' do
        described_class.spy_on(command_class) do |spy|
          allow(spy).to receive(:call)

          command_instance.call(*command_arguments)

          expect(spy).to have_received(:call).with(*command_arguments)
        end
      end

      it 'should execute the command implementation' do
        allow(command_instance).to receive(:process)

        described_class.spy_on(command_class) do
          command_instance.call(*command_arguments)
        end

        expect(command_instance)
          .to have_received(:process)
          .with(*command_arguments)
      end

      wrap_context 'when there is an instance spy on a command class' do
        it { expect(described_class.spy_on(command_class) { nil }).to be nil }

        it 'should yield the existing spy', :aggregate_failures do
          block_called = false

          described_class.spy_on(command_class) do |spy|
            block_called = true

            expect(spy).to be instance_spy
          end

          expect(block_called).to be true
        end
      end
    end

    describe 'with Cuprum::Operation' do
      let(:command_class)    { Spec::ExampleOperation }
      let(:command_instance) { command_class.new }

      it 'should return a spy' do
        spy = described_class.spy_on(Cuprum::Operation)

        expect(spy).to be_a described_class::Spy
      end

      it 'should instrument calls to #call on a subclass' do
        spy = described_class.spy_on(Cuprum::Operation)

        allow(spy).to receive(:call)

        command_instance.call(*command_arguments)

        expect(spy).to have_received(:call).with(*command_arguments)
      end
    end

    describe 'with a module' do
      let(:command_class)    { Spec::ExampleOperation }
      let(:command_instance) { command_class.new }

      it 'should return a spy' do
        spy = described_class.spy_on(Cuprum::Operation::Mixin)

        expect(spy).to be_a described_class::Spy
      end

      it 'should instrument calls to #call' do
        spy = described_class.spy_on(Cuprum::Operation::Mixin)

        allow(spy).to receive(:call)

        command_instance.call(*command_arguments)

        expect(spy).to have_received(:call).with(*command_arguments)
      end

      it 'should execute the command implementation' do
        allow(command_instance).to receive(:process)

        described_class.spy_on(Cuprum::Operation::Mixin)

        command_instance.call(*command_arguments)

        expect(command_instance)
          .to have_received(:process)
          .with(*command_arguments)
      end
    end

    wrap_context 'when there is an instance spy on a command class' do
      describe 'with a command subclass' do
        let(:command_subclass) { Class.new(command_class) }
        let(:command_instance) { command_subclass.new }

        it 'should return a spy', :aggregate_failures do
          spy = described_class.spy_on(command_subclass)

          expect(spy).to be_a described_class::Spy
          expect(spy).not_to be instance_spy
        end

        it 'should instrument calls to #call on the subclass',
          :aggregate_failures \
        do
          spy = described_class.spy_on(command_subclass)

          allow(instance_spy).to receive(:call)
          allow(spy).to receive(:call)

          command_instance.call(*command_arguments)

          expect(instance_spy).to have_received(:call).with(*command_arguments)
          expect(spy).to have_received(:call).with(*command_arguments)
        end

        it 'should not instrument calls in other threads' do
          allow(instance_spy).to receive(:call)

          Thread.new { command_instance.call(*command_arguments) }.join

          expect(instance_spy).not_to have_received(:call)
        end
      end
    end
  end
end
