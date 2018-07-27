require 'cuprum'

require 'sleeping_king_studios/tools/toolbelt'

module Cuprum
  # Builder class for instantiating command objects.
  #
  # @example
  #   class SpaceFactory < Cuprum::CommandFactory
  #     command :build, BuildCommand
  #
  #     command :fly { |launch_site:| FlyCommand.new(launch_site) }
  #   end
  #
  #   factory = SpaceFactory.new
  #
  #   factory::Build #=> BuildCommand
  #   # OR
  #   factory.build  #=> an instance of BuildCommand
  #
  #   rocket = factory.build.call({ size: 'big' }) #=> an instance of Rocket
  #   rocket.size                                  #=> 'big'
  #
  #   command = factory.fly(launch_site: 'KSC') #=> an instance of FlyCommand
  #   command.call(rocket)
  #   #=> launches the rocket from KSC
  class CommandFactory < Module
    # Defines the Domain-Specific Language and helper methods for dynamically
    # defined commands.
    class << self
      ABSTRACT_ERROR_MESSAGE =
        'Cuprum::CommandFactory is an abstract class. Create a subclass to ' \
        'define commands for a factory.'.freeze
      private_constant :ABSTRACT_ERROR_MESSAGE

      INVALID_DEFINITION_ERROR_MESSAGE =
        'definition must be a command class'.freeze
      private_constant :INVALID_DEFINITION_ERROR_MESSAGE

      MISSING_DEFINITION_ERROR_MESSAGE =
        'must provide a command class or a block'.freeze
      private_constant :MISSING_DEFINITION_ERROR_MESSAGE

      # Defines a command for the factory.
      #
      # @overload command(name, command_class)
      #   Defines a command using the given factory class. The command class can
      #   be accessed from a factory instance as a constant factory::Name, and
      #   the method factory.name() will build an instance of the class.
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
      #   Defines a command using the given block. The method factory.name()
      #   will execute the block in the context of the factory instance (this
      #   allows you to use methods or instance variables from the factory) and
      #   will return the created command instance.
      #
      #   @param name [String, Symbol] The name of the command.
      #
      #   @yield The block will be executed in the context of the factory
      #     instance.
      #   @yieldparam *args [Array] Any arguments given to the method
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
      def command(name, command_class = nil, &defn)
        guard_abstract_factory!

        if command_class
          define_command_from_class(command_class, name: name)
        elsif block_given?
          define_command_from_block(defn, name: name)
        else
          require_definition!
        end
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

      def command_builder(command_class)
        ->(*args, &block) { command_class.new(*args, &block) }
      end

      def define_command_from_block(builder, name:)
        name = normalize_command_name(name)

        (@command_definitions ||= {})[name] = {}

        define_method(name) do |*args|
          instance_exec(*args, &builder)
        end
      end

      def define_command_from_class(command_class, name:)
        guard_invalid_definition!(command_class)

        builder = command_builder(command_class)
        name    = normalize_command_name(name)

        (@command_definitions ||= {})[name] = command_class

        define_method(name) { |*args, &block| builder.call(*args, &block) }
      end

      def guard_abstract_factory!
        raise NotImplementedError, ABSTRACT_ERROR_MESSAGE if abstract_factory?
      end

      def guard_invalid_definition!(command_class)
        return if command_class.is_a?(Class) && command_class < Cuprum::Command

        raise ArgumentError, INVALID_DEFINITION_ERROR_MESSAGE
      end

      def normalize_command_name(command_name)
        tools.string.underscore(command_name).intern
      end

      def require_definition!
        raise ArgumentError, MISSING_DEFINITION_ERROR_MESSAGE
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
    def const_defined?(const_name, inherit = true)
      command?(const_name) || super
    end

    # @private
    def const_missing(const_name)
      definitions  = self.class.send(:command_definitions)
      command_name = normalize_command_name(const_name)
      command_defn = definitions[command_name]

      return super unless command_defn

      const_set(const_name, command_defn)

      command_defn
    end

    private

    def normalize_command_name(command_name)
      self.class.send(:normalize_command_name, command_name)
    end
  end
end
