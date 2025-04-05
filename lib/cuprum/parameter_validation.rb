# frozen_string_literal: true

require 'sleeping_king_studios/tools'

require 'cuprum'
require 'cuprum/utils/parameters_mapping'

module Cuprum
  # Mixin for declaring validations for command parameters.
  module ParameterValidation
    extend SleepingKingStudios::Tools::Toolbox::Mixin

    autoload :ValidationRule, 'cuprum/parameter_validation/validation_rule'
    autoload :Validator,      'cuprum/parameter_validation/validator'

    # Class methods for parameter validation.
    module ClassMethods
      # @private
      def each_validation(&)
        return enum_for(:each_validation) unless block_given?

        ancestors.reverse_each do |ancestor|
          next unless ancestor.respond_to?(:validation_rules, true)

          ancestor.validation_rules.each(&)
        end
      end

      # @overload validate(name, **options)
      #   Defines a validation for the specified parameter.
      #
      #   This validation will call the #validate_$name method on the command
      #   with the value of the named parameter. If the method returns a failure
      #   message, that message is added to the failed validations.
      #
      #   @param name [String, Symbol] the parameter to validate.
      #   @param options [Hash] additional options to pass to the validation
      #     method.
      #
      #   @option options as [String, Symbol] the name of the parameter as
      #     displayed in the failure message, if any. Defaults to the value of
      #     the name parameter.
      #
      #   @return void
      #
      # @overload validate(name, using:, **options)
      #   Defines a validation for the specified parameter.
      #
      #   This validation will call the named method on the command with the
      #   value of the named parameter. If the method returns a failure message,
      #   that message is added to the failed validations.
      #
      #   @param name [String, Symbol] the parameter to validate.
      #   @param using [String, Symbol] the name of the method used to validate
      #     the parameter.
      #   @param options [Hash] additional options to pass to the validation
      #     method.
      #
      #   @option options as [String, Symbol] the name of the parameter as
      #     displayed in the failure message, if any. Defaults to the value of
      #     the name parameter.
      #
      #   @return void
      #
      # @overload validate(name, **options, &block)
      #   Defines a validation for the specified parameter.
      #
      #   This validation will call the given block with the value of the named
      #   parameter. If the block returns nil or false, a failure message is
      #   added to the failed validations
      #
      #   @param name [String, Symbol] the parameter to validate.
      #   @param options [Hash] additional options for the validation.
      #
      #   @option options as [String, Symbol] the name of the parameter as
      #     displayed in the failure message, if any. Defaults to the value of
      #     the name parameter.
      #   @option options message [String] the failure message to display.
      #     Defaults to "$name is invalid".
      #
      #   @yield the block to validate the parameter.
      #   @yieldparam value [Object] the value of the named parameter.
      #   @yieldreturn [true, false] true if the given value is valid for the
      #     parameter; otherwise false.
      #
      #   @return void
      #
      # @overload validate(name, type, **options)
      #   Defines a validation for the specified parameter.
      #
      #   This validation will call the #validate_$type method on the command
      #   with the value of the named parameter. If the method returns a failure
      #   message, that message is added to the failed validations.
      #
      #   If the command does not define the method, it will call the
      #   SleepingKingStudios::Tools::Assertions instance method with the same
      #   name. If the validation fails, the failure message is added to the
      #   failed validations.
      #
      #   @param name [String, Symbol] the parameter to validate.
      #   @param type [String, Symbol] the validation method to run.
      #   @param options [Hash] additional options to pass to the validation
      #     method.
      #
      #   @option options as [String, Symbol] the name of the parameter as
      #     displayed in the failure message, if any. Defaults to the value of
      #     the name parameter.
      #   @option options message [String] the message to display on a failed
      #     validation.
      #
      #   @raise [Cuprum::ParameterValidation::Validator::UnknownValidationError]
      #     if neither the command nor the standard tools defines the method.
      def validate(name, type = nil, using: nil, **options, &)
        tools.assertions.validate_name(name, as: 'name')

        if type && !type.is_a?(Module)
          tools.assertions.validate_name(type, as: 'type')
        end

        tools.assertions.validate_name(using, as: 'using') if using

        validation_rules <<
          build_validation_rule(name:, options:, type:, using:, &)
      end

      # @private
      def validate_parameters(command, ...)
        parameters = parameters_mapping.call(...)
        rules      = each_validation

        Validator.new.call(command:, parameters:, rules:)
      rescue NameError => exception
        raise unless exception.name == :process

        error = Cuprum::Errors::CommandNotImplemented.new(command:)

        Cuprum::Result.new(error:)
      end

      protected

      def validation_rules
        @validation_rules ||= []
      end

      private

      def build_block_validation(name, **options, &)
        type = ValidationRule::BLOCK_VALIDATION_TYPE

        ValidationRule.new(name:, type:, as: name.to_s, **options, &)
      end

      def build_method_validation(name, method_name, **options)
        type = ValidationRule::NAMED_VALIDATION_TYPE

        ValidationRule.new(name:, type:, as: name.to_s, method_name:, **options)
      end

      def build_named_validation(name, **options)
        type = ValidationRule::NAMED_VALIDATION_TYPE

        ValidationRule.new(name:, type:, as: name.to_s, **options)
      end

      def build_type_validation(name, type, **options)
        unless type.is_a?(Module)
          return ValidationRule.new(name:, type:, as: name.to_s, **options)
        end

        ValidationRule.new(
          name:,
          type:     :instance_of,
          as:       name.to_s,
          expected: type,
          **options
        )
      end

      def build_validation_rule(name:, options:, type:, using:, &)
        return build_type_validation(name, type, **options) if type

        return build_method_validation(name, using, **options) if using

        return build_block_validation(name, **options, &) if block_given?

        build_named_validation(name, **options)
      end

      def parameters_mapping
        @parameters_mapping ||=
          Cuprum::Utils::ParametersMapping.build(instance_method(:process))
      end

      def tools
        SleepingKingStudios::Tools::Toolbelt.instance
      end
    end

    # @overload call(*arguments, **keywords, &block)
    #   Validates the parameters and passes them to super.
    #
    #   @param arguments [Array] the arguments to validate.
    #   @param keywords [Hash] the keywords to validate.
    #   @param block [Proc] the block to validate, if any,
    #
    #   @return [Cuprum::Result] a failing result with a
    #     Cuprum::Errors::InvalidParameters error if the validation fails;
    #     otherwise the normal result of calling the command.
    #
    #   @see Cuprum::Processing#call.
    def call(...)
      result = self.class.validate_parameters(self, ...)

      return result if result.failure?

      super
    end
  end
end
