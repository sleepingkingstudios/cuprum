# frozen_string_literal: true

require 'cuprum/command'

require 'support/errors/not_valid'

module Spec::Commands
  class BuildModel < Cuprum::Command
    def initialize(model_class)
      super()

      @model_class = model_class
    end

    attr_reader :model_class

    private

    def process(attributes:)
      model_class.new(attributes: attributes)
    end
  end
end
