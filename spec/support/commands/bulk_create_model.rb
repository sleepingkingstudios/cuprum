# frozen_string_literal: true

require 'cuprum/map_command'

require 'support/commands/create_model'

module Spec::Commands
  class BulkCreateModel < Cuprum::MapCommand
    def initialize(model_class)
      super()

      @model_class = model_class
    end

    attr_reader :model_class

    private

    def create_command
      @create_command ||= Spec::Commands::CreateModel.new(model_class)
    end

    def process(attributes)
      create_command.call(attributes:)
    end
  end
end
