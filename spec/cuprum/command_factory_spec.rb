require 'cuprum/command'
require 'cuprum/command_factory'

RSpec.describe Cuprum::CommandFactory do
  shared_context 'when a factory subclass is defined' do
    let(:described_class) { Spec::ExampleCommandFactory }

    # rubocop:disable RSpec/DescribedClass
    options = { base_class: Cuprum::CommandFactory }
    # rubocop:enable RSpec/DescribedClass
    example_class 'Spec::ExampleCommandFactory', options
  end

  shared_context 'when a factory subclass is subclassed' do
    include_context 'when a factory subclass is defined'

    let(:instance) { Spec::FactorySubclass.new }

    example_class 'Spec::FactorySubclass',
      base_class: 'Spec::ExampleCommandFactory'
  end

  shared_context 'when a command is defined with a block' do
    let(:command_name)  { 'cut' }
    let(:command_class) { Spec::CutCommand }

    example_class 'Spec::CutCommand', base_class: Cuprum::Command

    before(:example) do
      klass = command_class

      described_class.command(command_name) { |*args| klass.new(*args) }
    end
  end

  shared_context 'when a command is defined with a command class' do
    let(:command_name)  { 'strength' }
    let(:command_class) { Spec::StrengthCommand }

    example_class 'Spec::StrengthCommand', base_class: Cuprum::Command

    before(:example) do
      described_class.command(command_name, command_class)
    end
  end

  shared_context 'when a command class is defined with a block' do
    let(:command_name)  { 'waterfall' }
    let(:command_class) { Spec::WaterfallCommand }

    example_class 'Spec::WaterfallCommand', base_class: Cuprum::Command

    before(:example) do
      klass = command_class

      described_class.command_class(command_name) { klass }
    end
  end

  shared_context 'when the factory defines a custom #build_command method' do
    let(:default_options) { { state: { value: 'a value'.freeze } } }

    before(:example) do
      opts = default_options

      Spec::ExampleCommandFactory.send :define_method, :build_command \
      do |klass, *args, **kwargs, &block|
        kwargs = kwargs.merge(opts)

        klass.new(*args, **kwargs, &block)
      end
    end
  end

  shared_examples 'should define the constant' do
    describe '::${CommandName}' do
      before(:example) { define_command }

      it 'should define the constant' do
        expect(instance)
          .to have_constant(constant_name)
          .with_value(command_class)
      end
    end
  end

  shared_examples 'should define the helper method' do
    # rubocop:disable RSpec/NestedGroups
    describe '#${command_name}' do
      before(:example) { define_command }

      def build_command
        instance.send(command_name, *arguments)
      end

      it { expect(instance).to respond_to(command_name).with(0).arguments }

      it { expect(build_command).to be_a command_class }

      context 'when the command has constructor arguments' do
        let(:command_class) { Spec::FlyCommand }
        let(:command_name)  { 'fly' }

        it 'should define the method' do
          expect(instance)
            .to respond_to(command_name)
            .with(0..arguments.count).arguments
        end

        describe 'with no arguments' do
          it { expect(build_command).to be_a command_class }

          it { expect(build_command.value).to be nil }

          it { expect(build_command.options).to be == {} }
        end

        describe 'with arguments' do
          let(:value)     { 'value'.freeze }
          let(:options)   { { key: 'option'.freeze } }
          let(:arguments) { [value, options] }

          it { expect(build_command).to be_a command_class }

          it { expect(build_command.value).to be == value }

          it { expect(build_command.options).to be == options }
        end
      end
    end
    # rubocop:enable RSpec/NestedGroups
  end

  shared_examples 'should call the #build_command method' do
    include_context 'when the factory defines a custom #build_command method'

    let(:command_class) { Spec::FlyCommand }
    let(:command_name)  { 'fly' }
    let(:command)       { instance.send(command_name, *arguments) }

    before(:example) { define_command }

    describe 'with no arguments' do
      it { expect(command).to be_a command_class }

      it { expect(command.value).to be nil }

      it { expect(command.options).to be == default_options }
    end

    describe 'with arguments' do
      let(:value)     { 'value'.freeze }
      let(:options)   { { key: 'option'.freeze } }
      let(:arguments) { [value, options] }

      it { expect(command).to be_a command_class }

      it { expect(command.value).to be == value }

      it 'should merge the options' do
        expect(command.options).to be == default_options.merge(options)
      end
    end
  end

  subject(:instance) { described_class.new }

  example_class 'Spec::SurfCommand', base_class: Cuprum::Command

  example_class 'Spec::FlyCommand', base_class: Cuprum::Command do |klass|
    klass.class_eval do
      def initialize(value = nil, **options)
        @value   = value
        @options = options
      end

      attr_reader :options, :value
    end
  end

  describe '::command' do
    let(:command_class) { Spec::SurfCommand }
    let(:command_name)  { 'surf' }
    let(:constant_name) { tools.string.camelize(command_name) }
    let(:arguments)     { [] }
    let(:metadata)      { {} }
    let(:definition) do
      described_class.send(:command_definitions)[command_name.intern]
    end
    let(:tools) do
      SleepingKingStudios::Tools::Toolbelt.instance
    end
    let(:error_message) do
      'Cuprum::CommandFactory is an abstract class. Create a subclass to ' \
      'define commands for a factory.'
    end

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:command)
        .with(1..2).arguments
        .and_any_keywords
        .and_a_block
    end

    describe 'with a name' do
      it 'should raise an error' do
        expect { described_class.command(command_name) }
          .to raise_error NotImplementedError, error_message
      end
    end

    describe 'with a name and a block' do
      it 'should raise an error' do
        expect do
          described_class.command(command_name) { Spec::SurfCommand.new }
        end
          .to raise_error NotImplementedError, error_message
      end
    end

    describe 'with a name and a command class' do
      it 'should raise an error' do
        expect { described_class.command(command_name, Spec::SurfCommand) }
          .to raise_error NotImplementedError, error_message
      end
    end

    wrap_context 'when a factory subclass is defined' do
      describe 'with a name' do
        let(:error_message) { 'must provide a command class or a block' }

        it 'should raise an error' do
          expect { described_class.command(command_name) }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with a name and an invalid definition' do
        let(:definition)    { Cuprum::Command.new }
        let(:error_message) { 'definition must be a command class' }

        it 'should raise an error' do
          expect { described_class.command(command_name, definition) }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with a name and a block' do
        def define_command
          klass = command_class

          described_class.command(command_name) do |*args|
            build_command(klass, *args)
          end
        end

        include_examples 'should define the helper method'

        it 'should set the definition' do
          define_command

          expect(definition).to be_a Hash
        end

        it 'should not set a class definition' do
          define_command

          expect(definition[:__const_defn__]).to be nil
        end

        it 'should not set metadata' do
          define_command

          expect(definition.reject { |k, _| k == :__const_defn__ }).to be == {}
        end

        wrap_examples 'should call the #build_command method'
      end

      describe 'with a name, a block, and metadata' do
        let(:metadata) { { key: 'value', opt: 5 } }

        def define_command
          klass = command_class

          described_class.command(command_name, **metadata) do |*args|
            build_command(klass, *args)
          end
        end

        include_examples 'should define the helper method'

        it 'should set the definition' do
          define_command

          expect(definition).to be_a Hash
        end

        it 'should not set a class definition' do
          define_command

          expect(definition[:__const_defn__]).to be nil
        end

        it 'should set the metadata' do
          define_command

          expect(definition.reject { |k, _| k == :__const_defn__ })
            .to be == metadata
        end

        wrap_examples 'should call the #build_command method'
      end

      describe 'with a name and a command class' do
        def define_command
          described_class.command(command_name, command_class)
        end

        include_examples 'should define the constant'

        include_examples 'should define the helper method'

        it 'should set the definition' do
          define_command

          expect(definition).to be_a Hash
        end

        it 'should set the class definition' do
          define_command

          expect(definition[:__const_defn__]).to be command_class
        end

        it 'should not set metadata' do
          define_command

          expect(definition.reject { |k, _| k == :__const_defn__ }).to be == {}
        end

        wrap_examples 'should call the #build_command method'
      end

      describe 'with a name, a command class, and metadata' do
        let(:metadata) { { key: 'value', opt: 5 } }

        def define_command
          described_class.command(command_name, command_class, **metadata)
        end

        include_examples 'should define the constant'

        include_examples 'should define the helper method'

        it 'should set the definition' do
          define_command

          expect(definition).to be_a Hash
        end

        it 'should set the class definition' do
          define_command

          expect(definition[:__const_defn__]).to be command_class
        end

        it 'should set the metadata' do
          define_command

          expect(definition.reject { |k, _| k == :__const_defn__ })
            .to be == metadata
        end

        wrap_examples 'should call the #build_command method'
      end
    end

    wrap_context 'when a factory subclass is subclassed' do
      describe 'with a name' do
        let(:error_message) { 'must provide a command class or a block' }

        it 'should raise an error' do
          expect { described_class.command(command_name) }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with a name and an invalid definition' do
        let(:definition)    { Cuprum::Command.new }
        let(:error_message) { 'definition must be a command class' }

        it 'should raise an error' do
          expect { described_class.command(command_name, definition) }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with a name and a block' do
        def define_command
          klass = command_class

          described_class.command(command_name) do |*args|
            build_command(klass, *args)
          end
        end

        include_examples 'should define the helper method'

        it 'should set the definition' do
          define_command

          expect(definition).to be_a Hash
        end

        it 'should not set a class definition' do
          define_command

          expect(definition[:__const_defn__]).to be nil
        end

        it 'should not set metadata' do
          define_command

          expect(definition.reject { |k, _| k == :__const_defn__ }).to be == {}
        end

        wrap_examples 'should call the #build_command method'
      end

      describe 'with a name, a block, and metadata' do
        let(:metadata) { { key: 'value', opt: 5 } }

        def define_command
          klass = command_class

          described_class.command(command_name, **metadata) do |*args|
            build_command(klass, *args)
          end
        end

        include_examples 'should define the helper method'

        it 'should set the definition' do
          define_command

          expect(definition).to be_a Hash
        end

        it 'should not set a class definition' do
          define_command

          expect(definition[:__const_defn__]).to be nil
        end

        it 'should set the metadata' do
          define_command

          expect(definition.reject { |k, _| k == :__const_defn__ })
            .to be == metadata
        end

        wrap_examples 'should call the #build_command method'
      end

      describe 'with a name and a command class' do
        def define_command
          described_class.command(command_name, command_class)
        end

        include_examples 'should define the constant'

        include_examples 'should define the helper method'

        it 'should set the definition' do
          define_command

          expect(definition).to be_a Hash
        end

        it 'should set the class definition' do
          define_command

          expect(definition[:__const_defn__]).to be command_class
        end

        it 'should not set metadata' do
          define_command

          expect(definition.reject { |k, _| k == :__const_defn__ }).to be == {}
        end

        wrap_examples 'should call the #build_command method'
      end

      describe 'with a name, a command class, and metadata' do
        let(:metadata) { { key: 'value', opt: 5 } }

        def define_command
          described_class.command(command_name, command_class, **metadata)
        end

        include_examples 'should define the constant'

        include_examples 'should define the helper method'

        it 'should set the definition' do
          define_command

          expect(definition).to be_a Hash
        end

        it 'should set the class definition' do
          define_command

          expect(definition[:__const_defn__]).to be command_class
        end

        it 'should set the metadata' do
          define_command

          expect(definition.reject { |k, _| k == :__const_defn__ })
            .to be == metadata
        end

        wrap_examples 'should call the #build_command method'
      end
    end
  end

  describe '::command_class' do
    let(:command_class) { Spec::SurfCommand }
    let(:command_name)  { 'surf' }
    let(:constant_name) { tools.string.camelize(command_name) }
    let(:arguments)     { [] }
    let(:metadata)      { {} }
    let(:definition) do
      described_class.send(:command_definitions)[command_name.intern]
    end
    let(:tools) do
      SleepingKingStudios::Tools::Toolbelt.instance
    end
    let(:error_message) do
      'Cuprum::CommandFactory is an abstract class. Create a subclass to ' \
      'define commands for a factory.'
    end

    it 'should define the class method' do
      expect(described_class)
        .to respond_to(:command_class)
        .with(1).argument
        .and_any_keywords
        .and_a_block
    end

    describe 'with a name' do
      it 'should raise an error' do
        expect { described_class.command_class(command_name) }
          .to raise_error NotImplementedError, error_message
      end
    end

    describe 'with a name and a block' do
      it 'should raise an error' do
        expect do
          described_class.command_class(command_name) { Spec::SurfCommand }
        end
          .to raise_error NotImplementedError, error_message
      end
    end

    wrap_context 'when a factory subclass is defined' do
      describe 'with a name' do
        let(:error_message) { 'must provide a block' }

        it 'should raise an error' do
          expect { described_class.command_class(command_name) }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with a name and a block' do
        def define_command
          klass = command_class

          described_class.command_class(command_name) { klass }
        end

        include_examples 'should define the constant'

        include_examples 'should define the helper method'

        it 'should set the definition' do
          define_command

          expect(definition).to be_a Hash
        end

        it 'should set a class definition' do
          define_command

          expect(definition[:__const_defn__]).to be_a Proc
        end

        it 'should not set metadata' do
          define_command

          expect(definition.reject { |k, _| k == :__const_defn__ }).to be == {}
        end

        wrap_examples 'should call the #build_command method'
      end

      describe 'with a name, a block, and metadata' do
        let(:metadata) { { key: 'value', opt: 5 } }

        def define_command
          klass = command_class

          described_class.command_class(command_name, **metadata) { klass }
        end

        include_examples 'should define the constant'

        include_examples 'should define the helper method'

        it 'should set the definition' do
          define_command

          expect(definition).to be_a Hash
        end

        it 'should set a class definition' do
          define_command

          expect(definition[:__const_defn__]).to be_a Proc
        end

        it 'should not set metadata' do
          define_command

          expect(definition.reject { |k, _| k == :__const_defn__ })
            .to be == metadata
        end

        wrap_examples 'should call the #build_command method'
      end
    end

    wrap_context 'when a factory subclass is subclassed' do
      describe 'with a name' do
        let(:error_message) { 'must provide a block' }

        it 'should raise an error' do
          expect { described_class.command_class(command_name) }
            .to raise_error ArgumentError, error_message
        end
      end

      describe 'with a name and a block' do
        def define_command
          klass = command_class

          described_class.command_class(command_name) { klass }
        end

        include_examples 'should define the constant'

        include_examples 'should define the helper method'

        it 'should set the definition' do
          define_command

          expect(definition).to be_a Hash
        end

        it 'should set a class definition' do
          define_command

          expect(definition[:__const_defn__]).to be_a Proc
        end

        it 'should not set metadata' do
          define_command

          expect(definition.reject { |k, _| k == :__const_defn__ }).to be == {}
        end

        wrap_examples 'should call the #build_command method'
      end

      describe 'with a name, a block, and metadata' do
        let(:metadata) { { key: 'value', opt: 5 } }

        def define_command
          klass = command_class

          described_class.command_class(command_name, **metadata) { klass }
        end

        include_examples 'should define the constant'

        include_examples 'should define the helper method'

        it 'should set the definition' do
          define_command

          expect(definition).to be_a Hash
        end

        it 'should set a class definition' do
          define_command

          expect(definition[:__const_defn__]).to be_a Proc
        end

        it 'should not set metadata' do
          define_command

          expect(definition.reject { |k, _| k == :__const_defn__ })
            .to be == metadata
        end

        wrap_examples 'should call the #build_command method'
      end
    end
  end

  describe '#command?' do
    it { expect(instance).to respond_to(:command?).with(1).argument }

    it { expect(instance.command?(:defenestrate)).to be false }

    wrap_context 'when a factory subclass is defined' do
      wrap_context 'when a command is defined with a block' do
        describe 'with an invalid command name' do
          it { expect(instance.command?(:defenestrate)).to be false }
        end

        describe 'with a valid command name as a string' do
          it { expect(instance.command?(command_name.to_s)).to be true }
        end

        describe 'with a valid command name as a symbol' do
          it { expect(instance.command?(command_name.intern)).to be true }
        end
      end

      wrap_context 'when a command is defined with a command class' do
        describe 'with an invalid command name' do
          it { expect(instance.command?(:defenestrate)).to be false }
        end

        describe 'with a valid command name as a string' do
          it { expect(instance.command?(command_name.to_s)).to be true }
        end

        describe 'with a valid command name as a symbol' do
          it { expect(instance.command?(command_name.intern)).to be true }
        end
      end

      wrap_context 'when a command class is defined with a block' do
        describe 'with an invalid command name' do
          it { expect(instance.command?(:defenestrate)).to be false }
        end

        describe 'with a valid command name as a string' do
          it { expect(instance.command?(command_name.to_s)).to be true }
        end

        describe 'with a valid command name as a symbol' do
          it { expect(instance.command?(command_name.intern)).to be true }
        end
      end
    end

    wrap_context 'when a factory subclass is subclassed' do
      wrap_context 'when a command is defined with a block' do
        describe 'with an invalid command name' do
          it { expect(instance.command?(:defenestrate)).to be false }
        end

        describe 'with a valid command name as a string' do
          it { expect(instance.command?(command_name.to_s)).to be true }
        end

        describe 'with a valid command name as a symbol' do
          it { expect(instance.command?(command_name.intern)).to be true }
        end
      end

      wrap_context 'when a command is defined with a command class' do
        describe 'with an invalid command name' do
          it { expect(instance.command?(:defenestrate)).to be false }
        end

        describe 'with a valid command name as a string' do
          it { expect(instance.command?(command_name.to_s)).to be true }
        end

        describe 'with a valid command name as a symbol' do
          it { expect(instance.command?(command_name.intern)).to be true }
        end
      end

      wrap_context 'when a command class is defined with a block' do
        describe 'with an invalid command name' do
          it { expect(instance.command?(:defenestrate)).to be false }
        end

        describe 'with a valid command name as a string' do
          it { expect(instance.command?(command_name.to_s)).to be true }
        end

        describe 'with a valid command name as a symbol' do
          it { expect(instance.command?(command_name.intern)).to be true }
        end
      end
    end
  end

  describe '#commands' do
    include_examples 'should have reader', :commands, -> { be == [] }

    wrap_context 'when a factory subclass is defined' do
      wrap_context 'when a command is defined with a block' do
        it { expect(instance.commands).to contain_exactly(command_name.intern) }
      end

      wrap_context 'when a command is defined with a command class' do
        it { expect(instance.commands).to contain_exactly(command_name.intern) }
      end

      wrap_context 'when a command class is defined with a block' do
        it { expect(instance.commands).to contain_exactly(command_name.intern) }
      end
    end

    wrap_context 'when a factory subclass is subclassed' do
      wrap_context 'when a command is defined with a block' do
        it { expect(instance.commands).to contain_exactly(command_name.intern) }
      end

      wrap_context 'when a command is defined with a command class' do
        it { expect(instance.commands).to contain_exactly(command_name.intern) }
      end

      wrap_context 'when a command class is defined with a block' do
        it { expect(instance.commands).to contain_exactly(command_name.intern) }
      end
    end
  end
end
