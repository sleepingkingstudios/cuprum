require 'weakref'

require 'cuprum/built_in/null_function'
require 'cuprum/utils'

module Cuprum::Utils
  # Utility module for instrumenting calls to the #call method of a function.
  module InstanceSpy
    class << self
      def clear_spies
        # TODO: This is not thread-safe.
        @spies = {}
      end # method clear_spies

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

    # Minimal class that implements a #call method to mirror method calls to
    # instances of an instrumented function class.
    class Spy
      def call *_args, &block; end
    end # class

    def call *args, &block
      Cuprum::Utils::InstanceSpy.send(:call_spies_for, self, *args, &block)

      super
    end # method call
  end # module
end # module
