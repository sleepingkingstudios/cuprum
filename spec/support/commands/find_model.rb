# frozen_string_literal: true

require 'cuprum/command'

require 'support/errors/not_found'

module Spec::Commands
  class FindModel < Cuprum::Command
    def initialize(model_class)
      super()

      @model_class = model_class
    end

    attr_reader :model_class

    private

    def not_found
      Spec::Errors::NotFound.new(model_class:)
    end

    def process(id:)
      model = model_class.find(id)

      return failure(not_found) unless model

      success(model)
    end
  end
end
