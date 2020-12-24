# frozen_string_literal: true

require 'cuprum/command'

require 'support/errors/not_found'

module Spec::Commands
  class FindOneAssociation < Cuprum::Command
    def initialize(foreign_key:, model_class:)
      super()

      @foreign_key = foreign_key
      @model_class = model_class
    end

    attr_reader :foreign_key

    attr_reader :model_class

    private

    def not_found
      Spec::Errors::NotFound.new(model_class: model_class)
    end

    def process(id:)
      model = model_class.each.find { |item| item.send(foreign_key) == id }

      return failure(not_found) unless model

      success(model)
    end
  end
end
