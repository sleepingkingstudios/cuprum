# frozen_string_literal: true

require 'cuprum/utils'

module Cuprum::Utils
  # Instruments calls to the #call method of any instance of a command class.
  #
  # This can be used to unobtrusively test the functionality of code that calls
  # a command without providing a reference to the command instance, such
  # methods that create and call a command instance.
  #
  # @example Observing calls to instances of a command.
  #   spy = Cuprum::Utils::InstanceSpy.spy_on(CustomCommand)
  #
  #   allow(spy).to receive(:call)
  #
  #   CustomCommand.new.call(1, 2, 3, :four => '4')
  #
  #   expect(spy).to have_received(:call).with(1, 2, 3, :four => '4')
  #
  # @example Block syntax
  #   Cuprum::Utils::InstanceSpy.spy_on(CustomCommand) do |spy|
  #     allow(spy).to receive(:call)
  #
  #     CustomCommand.new.call
  #
  #     expect(spy).to have_received(:call)
  #   end
  module InstanceSpy
    # Minimal class double implementing the #call method.
    class Spy
      # Empty method that accepts any parameters and an optional block.
      def call(*_args, **_kwargs, &block); end
    end

    class << self
      # Retires all spies.
      #
      # Subsequent calls to the #call method on command instances will not be
      # mirrored to existing spy objects.
      def clear_spies
        Thread.current[:cuprum_instance_spies] = nil

        nil
      end

      # Finds or creates a spy object for the given module or class.
      #
      # Each time that the #call method is called for an object of the given
      # type, the spy's #call method will be invoked with the same arguments and
      # block.
      #
      # @param command_class [Class, Module] The type of command to spy on.
      #   Must be either a Module, or a Class that extends Cuprum::Command.
      #
      # @raise [ArgumentError] If the argument is neither a Module nor a Class
      #   that extends Cuprum::Command.
      #
      # @note Calling this method for the first time will prepend the
      #   Cuprum::Utils::InstanceSpy module to Cuprum::Command.
      #
      # @overload spy_on(command_class)
      #   @return [Cuprum::Utils::InstanceSpy::Spy] The instance spy.
      #
      # @overload spy_on(command_class, &block)
      #   Yields the instance spy to the block, and returns nil.
      #
      #   @yield [Cuprum::Utils::InstanceSpy::Spy] The instance spy.
      #
      #   @return [nil] nil.
      def spy_on(command_class)
        guard_spy_class!(command_class)

        instrument_call!

        if block_given?
          instance_spy = assign_spy(command_class)

          yield instance_spy
        else
          assign_spy(command_class)
        end
      end

      private

      def assign_spy(command_class)
        existing_spy = spies[command_class]

        return existing_spy if existing_spy

        spies[command_class] = build_spy
      end

      def build_spy
        Cuprum::Utils::InstanceSpy::Spy.new
      end

      def call_spies_for(command, ...)
        spies_for(command).each { |spy| spy.call(...) }
      end

      def guard_spy_class!(command_class)
        return if command_class.is_a?(Module) && !command_class.is_a?(Class)

        return if command_class.is_a?(Class) &&
                  command_class <= Cuprum::Command

        raise ArgumentError,
          'must be a class inheriting from Cuprum::Command',
          caller(1..-1)
      end

      def instrument_call!
        return if Cuprum::Command < Cuprum::Utils::InstanceSpy

        Cuprum::Command.prepend(Cuprum::Utils::InstanceSpy)
      end

      def spies
        Thread.current[:cuprum_instance_spies] ||= {}
      end

      def spies_for(command)
        spies.select { |mod, _| command.is_a?(mod) }.map { |_, spy| spy }
      end
    end

    # (see Cuprum::Processing#call)
    def call(*args, **kwargs, &block)
      if kwargs.empty?
        Cuprum::Utils::InstanceSpy.send(:call_spies_for, self, *args, &block)
      else
        # :nocov:
        Cuprum::Utils::InstanceSpy
          .send(:call_spies_for, self, *args, **kwargs, &block)
        # :nocov:
      end

      super
    end
  end
end
