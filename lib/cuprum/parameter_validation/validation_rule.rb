# frozen_string_literal: true

require 'cuprum/parameter_validation'

module Cuprum::ParameterValidation
  # @api private
  #
  # Value class representing a single validation for a parameter.
  class ValidationRule < Struct.new( # rubocop:disable Style/StructInheritance
    :name,
    :type,
    :options,
    :block,
    keyword_init: true
  )
    # Custom validation type for a block validation.
    BLOCK_VALIDATION_TYPE = :_block_validation

    # Custom validation type for a named method validation.
    NAMED_VALIDATION_TYPE = :_named_method_validation

    # @param name [Symbol] the name of the parameter to validate.
    # @param type [Symbol] the type of validation to perform.
    # @param options [Hash] additional options to pass to the validator.
    # @param block [Proc] a block to pass to the validator, if any.
    def initialize(name:, type:, **options, &block)
      super(block:, name: name.to_sym, options:, type: type.to_sym)
    end
  end
end
