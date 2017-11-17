require 'cuprum/built_in/null_function'
require 'cuprum/utils'

module Cuprum::Utils
  # Utility module for instrumenting calls to the #call method of any instance
  # of a function class. This can be used to unobtrusively test the
  # functionality of code that calls a function without providing a reference to
  # the function instance, such as chained functions or methods that create and
  # call a function instance.
  #
  # @example Observing calls to instances of a function.
  #   spy = Cuprum::Utils::InstanceSpy.spy_on(CustomFunction)
  #
  #   expect(spy).to receive(:call).with(1, 2, 3, :four => '4')
  #
  #   CustomFunction.new.call(1, 2, 3, :four => '4')
  #
  # @example Observing calls to a chained function.
  #   spy = Cuprum::Utils::InstanceSpy.spy_on(ChainedFunction)
  #
  #   expect(spy).to receive(:call)
  #
  #   Cuprum::Function.new {}.
  #     chain { |result| ChainedFunction.new.call(result) }.
  #     call
  #
  # @example Block syntax
  #   Cuprum::Utils::InstanceSpy.spy_on(CustomFunction) do |spy|
  #     expect(spy).to receive(:call)
  #
  #     CustomFunction.new.call
  #   end # spy_on
  module InstanceSpy
    # Minimal class that implements a #call method to mirror method calls to
    # instances of an instrumented function class.
    class Spy
      # Empty method that accepts any arguments and an optional block.
      def call *_args, &block; end
    end # class

    class << self
      # Retires all spies. Subsequent calls to the #call method on function
      # instances will not be mirrored to existing spy objects.
      def clear_spies
        # TODO: This is not thread-safe.
        @spies = {}

        nil
      end # method clear_spies

      # Finds or creates a spy object for the given module or class. Each time
      # that the #call method is called for an object of the given type, the
      # spy's #call method will be invoked with the same arguments and block.
      #
      # @param function_class [Class, Module] The type of function to spy on.
      #   Must be either a Module, or a Class that extends Cuprum::Function.
      #
      # @raise [ArgumentError] If the argument is neither a Module nor a Class
      #   that extends Cuprum::Function.
      #
      # @note Calling this method for the first time will prepend the
      #   Cuprum::Utils::InstanceSpy module to Cuprum::Function.
      #
      # @overload spy_on(function_class)
      #   @return [Cuprum::Utils::InstanceSpy::Spy] The instance spy.
      #
      # @overload spy_on(function_class, &block)
      #   Yields the instance spy to the block, and returns nil.
      #
      #   @yield [Cuprum::Utils::InstanceSpy::Spy] The instance spy.
      #
      #   @return [nil] nil.
      def spy_on function_class
        guard_spy_class!(function_class)

        instrument_call!

        if block_given?
          begin
            instance_spy = assign_spy(function_class)

            yield instance_spy
          end # begin-ensure
        else
          assign_spy(function_class)
        end # if-else
      end # method spy_on

      private

      def assign_spy function_class
        existing_spy = spies[function_class]

        return existing_spy if existing_spy

        spies[function_class] = build_spy
      end # method assign_spy

      def build_spy
        Cuprum::Utils::InstanceSpy::Spy.new
      end # method build_spy

      def call_spies_for function, *args, &block
        spies_for(function).each { |spy| spy.call(*args, &block) }
      end # method call_spies_for

      def guard_spy_class! function_class
        return if function_class.is_a?(Module) && !function_class.is_a?(Class)

        return if function_class.is_a?(Class) &&
                  function_class <= Cuprum::Function

        raise ArgumentError,
          'must be a class inheriting from Cuprum::Function',
          caller(1..-1)
      end # method guard_spy_class!

      def instrument_call!
        return if Cuprum::Function < Cuprum::Utils::InstanceSpy

        Cuprum::Function.prepend(Cuprum::Utils::InstanceSpy)
      end # method instrument_call!

      def spies
        # TODO: This is not thread-safe.
        @spies ||= {}
      end # method spies

      def spies_for function
        spies.select { |mod, _| function.is_a?(mod) }.map { |_, spy| spy }
      end # method spies_for
    end # eigenclass

    # (see Cuprum::Function#call)
    def call *args, &block
      Cuprum::Utils::InstanceSpy.send(:call_spies_for, self, *args, &block)

      super
    end # method call
  end # module
end # module
