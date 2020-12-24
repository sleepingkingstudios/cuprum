# frozen_string_literal: true

require 'cuprum/command'

require 'support/commands/create_model'
require 'support/commands/find_model'
require 'support/commands/update_model'

module Spec::Commands
  class UpsertModel < Cuprum::Command
    def initialize(model_class)
      super()

      @model_class = model_class
    end

    attr_reader :model_class

    private

    def create_model(attributes:)
      Spec::Commands::CreateModel.new(model_class).call(attributes: attributes)
    end

    def find_model(id:)
      Spec::Commands::FindModel.new(model_class).call(id: id)
    end

    def process(attributes:)
      result = find_model(id: attributes[:id])

      if result.success?
        return update_model(attributes: attributes, model: result.value)
      end

      create_model(attributes: attributes)
    end

    def update_model(attributes:, model:)
      Spec::Commands::UpdateModel
        .new(model_class)
        .call(attributes: attributes, model: model)
    end
  end
end
