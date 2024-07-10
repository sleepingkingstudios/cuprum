# frozen_string_literal: true

require 'cuprum/command'

require 'support/commands/create_model'

module Spec::Commands
  class FindOrCreateModelBy < Cuprum::Command
    def initialize(model_class)
      super()

      @model_class = model_class
    end

    attr_reader :model_class

    private

    def create_model(attributes:)
      Spec::Commands::CreateModel.new(model_class).call(attributes:)
    end

    def find_model(attributes:)
      model_class.each.find { |item| item.attributes >= attributes }
    end

    def process(attributes:)
      model = find_model(attributes:)

      return success(model) if model

      create_model(attributes:)
    end
  end
end
