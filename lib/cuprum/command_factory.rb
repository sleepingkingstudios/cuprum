# frozen_string_literal: true

require 'cuprum'

require 'sleeping_king_studios/tools/toolbelt'

module Cuprum
  # Builder class for instantiating command objects.
  #
  # @example
  #   class SpaceFactory < Cuprum::CommandFactory
  #     command(:build, BuildCommand)
  #
  #     command(:fly) { |launch_site:| FlyCommand.new(launch_site) }
  #
  #     command_class(:dream) { DreamCommand }
  #   end
  #
  #   factory = SpaceFactory.new
  #
  #   factory::Build #=> BuildCommand
  #   factory.build  #=> an instance of BuildCommand
  #
  #   rocket = factory.build.call({ size: 'big' }) #=> an instance of Rocket
  #   rocket.size                                  #=> 'big'
  #
  #   command = factory.fly(launch_site: 'KSC') #=> an instance of FlyCommand
  #   command.call(rocket)
  #   #=> launches the rocket from KSC
  #
  #   factory::Dream #=> DreamCommand
  #   factory.dream  #=> an instance of DreamCommand
  class CommandFactory < Module # rubocop:disable Metrics/ClassLength
    # Defines the Domain-Specific Language and helper methods for dynamically
    # defined commands.
    class << self
      # Defines a command for the factory.
      #
      # @overload command(name, command_class)
      #   Defines a command using the given factory class. For example, when a
      #   command is defined with the name "whirlpool" and the WhirlpoolCommand
      #   class:
      #
      #   A factory instance will define the constant ::Whirlpool, and accessing
      #   factory::Whirlpool will return the WhirlpoolCommand class.
      #
      #   A factory instance will define the method #whirlpool, and calling
      #   factory#whirlpool will return an instance of WhirlpoolCommand. Any
      #   arguments passed to the #whirlpool method will be forwarded to the
      #   constructor when building the command.
      #
      #   @param name [String, Symbol] The name of the command.
      #   @param command_class [Class] The command class. Must be a subclass of
      #     Cuprum::Command.
      #
      #   @example
      #     class MoveFactory < Cuprum::CommandFactory
      #       command :cut, CutCommand
      #     end
      #
      #     factory = MoveFactory.new
      #     factory::Cut #=> CutCommand
      #     factory.cut  #=> an instance of CutCommand
      #
      # @overload command(name) { |*args| }
      #   Defines a command using the given block, which must return an instance
      #   of a Cuprum::Command subclass. For example, when a command is defined
      #   with the name "dive" and a block that returns an instance of the
      #   DiveCommand class:
      #
      #   A factory instance will define the method #dive, and calling
      #   factory#dive will call the block and return the resulting command
      #   instance. Any arguments passed to the #dive method will be forwarded
      #   to the block when building the command.
      #
      #   The block will be evaluated in the context of the factory instance, so
      #   it has access to any methods or instance variables defined for the
      #   factory instance.
      #
      #   @param name [String, Symbol] The name of the command.
      #
      #   @yield The block will be executed in the context of the factory
      #     instance.
      #   @yieldparam args [Array] Any arguments given to the method
      #     factory.name() will be passed on the block.
      #   @yieldreturn [Cuprum::Command] The block return an instance of a
      #     Cuprum::Command subclass, or else raise an error.
      #
      #   @example
      #     class MoveFactory < Cuprum::CommandFactory
      #       command :fly { |destination| FlyCommand.new(destination) }
      #     end
      #
      #     factory = MoveFactory.new
      #     factory.fly_command('Indigo Plateau')
      #     #=> an instance of FlyCommand with a destination of 'Indigo Plateau'
      def command(name, klass = nil, **metadata, &defn)
        guard_abstract_factory!

        if klass
          define_command_from_class(klass, name: name, metadata: metadata)
        elsif block_given?
          define_command_from_block(defn, name: name, metadata: metadata)
        else
          require_definition!
        end
      end

      # Defines a command using the given block, which must return a subclass of
      # Cuprum::Command. For example, when a command is defined with the name
      # "rock_climb" and a block returning a subclass of RockClimbCommand:
      #
      # A factory instance will define the constant ::RockClimb, and accessing
      # factory::RockClimb will call the block and return the resulting command
      # class. This value is memoized, so subsequent factory::RockClimb accesses
      # on the same factory instance will return the same command class.
      #
      # A factory instance will define the method #rock_climb, and calling
      # factory#rock_climb will access the constant at ::RockClimb and return an
      # instance of that subclass of RockClimbCommand. Any arguments passed to
      # the #whirlpool method will be forwarded to the constructor when building
      # the command.
      #
      # @param name [String, Symbol] The name of the command.
      # @yield The block will be executed in the context of the factory
      #   instance.
      # @yieldparam *args [Array] Any arguments given to the method
      #   factory.name() will be passed on the block.
      # @yieldreturn [Cuprum::Command] The block return an instance of a
      #   Cuprum::Command subclass, or else raise an error.
      #
      # @example
      #   class MoveFactory < Cuprum::CommandFactory
      #     command_class :flash do
      #       Class.new(FlashCommand) do
      #         def brightness
      #           :intense
      #         end
      #       end
      #     end
      #   end
      #
      #   factory = MoveFactory.new
      #   factory::Flash #=> a subclass of FlashCommand
      #   factory.flash  #=> an instance of factory::Flash
      #
      #   command = factory.flash
      #   command.brightness #=> :intense
      def command_class(name, **metadata, &defn)
        guard_abstract_factory!

        raise ArgumentError, 'must provide a block' unless block_given?

        method_name = normalize_command_name(name)

        (@command_definitions ||= {})[method_name] =
          metadata.merge(__const_defn__: defn)

        define_lazy_command_method(method_name)
      end

      protected

      def command_definitions
        definitions = (@command_definitions ||= {})

        return definitions unless superclass < Cuprum::CommandFactory

        superclass.command_definitions.merge(definitions)
      end

      private

      def abstract_factory?
        self == Cuprum::CommandFactory
      end

      def define_command_from_block(builder, name:, metadata: {})
        command_name = normalize_command_name(name)

        (@command_definitions ||= {})[command_name] = metadata

        define_method(command_name) do |*args, **kwargs|
          if kwargs.empty?
            instance_exec(*args, &builder)
          else
            instance_exec(*args, **kwargs, &builder)
          end
        end
      end

      def define_command_from_class(command_class, name:, metadata: {})
        guard_invalid_definition!(command_class)

        method_name = normalize_command_name(name)

        (@command_definitions ||= {})[method_name] =
          metadata.merge(__const_defn__: command_class)

        define_command_method(method_name, command_class)
      end

      def define_command_method(method_name, command_class)
        define_method(method_name) do |*args, **kwargs, &block|
          if kwargs.empty?
            build_command(command_class, *args, &block)
          else
            build_command(command_class, *args, **kwargs, &block)
          end
        end
      end

      def define_lazy_command_method(method_name)
        const_name = tools.string_tools.camelize(method_name)

        define_method(method_name) do |*args, **kwargs, &block|
          command_class = const_get(const_name)

          if kwargs.empty?
            build_command(command_class, *args, &block)
          else
            build_command(command_class, *args, **kwargs, &block)
          end
        end
      end

      def guard_abstract_factory!
        return unless abstract_factory?

        raise NotImplementedError,
          'Cuprum::CommandFactory is an abstract class. Create a subclass to ' \
          'define commands for a factory.'
      end

      def guard_invalid_definition!(command_class)
        return if command_class.is_a?(Class) && command_class < Cuprum::Command

        raise ArgumentError, 'definition must be a command class'
      end

      def normalize_command_name(command_name)
        tools.string_tools.underscore(command_name).intern
      end

      def require_definition!
        raise ArgumentError, 'must provide a command class or a block'
      end

      def tools
        SleepingKingStudios::Tools::Toolbelt.instance
      end
    end

    # @return [Boolean] true if the factory defines the given command, otherwise
    #   false.
    def command?(command_name)
      command_name = normalize_command_name(command_name)

      commands.include?(command_name)
    end

    # @return [Array<Symbol>] a list of the commands defined by the factory.
    def commands
      self.class.send(:command_definitions).keys
    end

    # @private
    def const_defined?(const_name, inherit = true) # rubocop:disable Style/OptionalBooleanParameter
      command?(const_name) || super
    end

    # @private
    def const_missing(const_name)
      definitions  = self.class.send(:command_definitions)
      command_name = normalize_command_name(const_name)
      command_defn = definitions.dig(command_name, :__const_defn__)

      return super unless command_defn

      command_class =
        command_defn.is_a?(Proc) ? instance_exec(&command_defn) : command_defn

      const_set(const_name, command_class)

      command_class
    end

    private

    def build_command(command_class, *args, **kwargs, &block)
      if kwargs.empty?
        command_class.new(*args, &block)
      else
        command_class.new(*args, **kwargs, &block)
      end
    end

    def normalize_command_name(command_name)
      self.class.send(:normalize_command_name, command_name)
    end
  end
end
