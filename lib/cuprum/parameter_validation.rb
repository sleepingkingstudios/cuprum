# frozen_string_literal: true

require 'set'

require 'sleeping_king_studios/tools/toolbox/mixin'

require 'cuprum'

module Cuprum
  module Errors
    class InvalidParameters < Cuprum::Error
      # Short string used to identify the type of error.
      TYPE = 'cuprum.errors.invalid_parameters'
    end
  end

  module ParameterValidation
    extend SleepingKingStudios::Tools::Toolbox::Mixin

    ParametersMapping =
      Data.define(:arguments, :keywords, :varargs, :varkwargs, :block) do
        def self.build(parameters)
          index     = 0
          arguments = {}
          keywords  = []
          varargs   = false
          varkwargs = false
          block     = false

          parameters.each do |(type, name)|
            case type
            when :req, :opt
              arguments[name] = index

              index += 1
            when :rest
              varargs = name
            when :keyreq, :key
              keywords << name
            when :keyrest
              varkwargs = name
            when :block
              block = name
            end
          end

          new(
            arguments:,
            keywords: Set.new(keywords),
            varargs:,
            varkwargs:,
            block:
          )
        end

        def call(*args, **kwargs, &block_param)
          mapping = {}
          keyrest = {}

          arguments.each { |name, index| mapping[name] = args[index] }

          mapping[varargs] = args[arguments.size..] if varargs

          kwargs.each do |name, value|
            (keywords.include?(name) ? mapping : keyrest)[name] = value
          end

          mapping[varkwargs] = keyrest if varkwargs

          mapping[block] = block_param

          mapping
        end
      end

    ValidationRule = Data.define(:name, :type, :options, :block)

    module ClassMethods
      # @api private
      def validations
        ancestors.reverse_each.reduce([]) do |memo, ancestor|
          next memo unless ancestor.respond_to?(:defined_validations, true)

          memo.concat(defined_validations)
        end
      end

      def validate(parameter_name, validation = nil, **options, &block)
        defined_validations <<
          if validation.is_a?(Module)
            ValidationRule.new(
              parameter_name,
              :instance_of,
              options.merge(expected: validation),
              nil
            )
          elsif validation.is_a?(String) || validation.is_a?(Symbol)
            ValidationRule.new(parameter_name, validation, options, nil)
          elsif validation.nil? && block_given?
            ValidationRule.new(parameter_name, :block, options, block)
          elsif validation.nil?
            ValidationRule.new(parameter_name, nil, options, nil)
          else
            raise 'oh no'
          end
      end

      protected

      def defined_validations
        @defined_validations ||= []
      end
    end

    class Validator < SleepingKingStudios::Tools::Assertions::Aggregator
      def initialize(receiver)
        super()

        @receiver = receiver
      end

      def call(parameters)
        receiver.class.validations.each do |rule|
          value = parameters[rule.name]
          mname = :"validate_#{rule.type || rule.name}"

          if rule.type == :block
            raise
          elsif receiver.respond_to?(mname, true)
            message = receiver.send(mname, value, as: rule.name, **rule.options)

            failures << message if message
          elsif respond_to?(mname)
            send(mname, value, as: rule.name, **rule.options)
          else
            raise 'oh no'
          end
        end

        self
      end

      private

      attr_reader :receiver
    end

    def call(*args, **kwargs, &block)
      validator = validate_parameters(*args, **kwargs, &block)

      return super if validator.empty?

      error = Cuprum::Errors::InvalidParameters.new(
        message: "invalid parameters for #{self.class.name} - #{validator.failure_message}"
      )
      failure(error)
    end

    private

    def collect_parameters(*args, **kwargs, &block)
      parameters_mapping.call(*args, **kwargs, &block)
    end

    def parameters_mapping
      @parameters_mapping ||=
        ParametersMapping.build(method(:process).parameters)
    end

    def validate_parameters(*args, **kwargs, &block)
      parameters = collect_parameters(*args, **kwargs, &block)

      Validator.new(self).call(parameters)
    end
  end
end
