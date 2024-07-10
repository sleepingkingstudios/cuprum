# frozen_string_literal: true

require 'cuprum/command'

require 'support/errors/not_valid'

module Spec::Commands
  class UpdateModel < Cuprum::Command
    def initialize(model_class)
      super()

      @model_class = model_class
    end

    attr_reader :model_class

    private

    def not_valid(model)
      Spec::Errors::NotValid.new(
        errors:      model.errors,
        model_class:
      )
    end

    def process(attributes:, model:)
      model.update_attributes(attributes:)

      return failure(not_valid(model)) unless model.valid?

      model.save

      model
    end
  end
end
