# frozen_string_literal: true

require 'cuprum'

module Cuprum
  # Mixin for declaring validations for command parameters.
  module ParameterValidation
    autoload :ValidationRule, 'cuprum/parameter_validation/validation_rule'
  end
end
