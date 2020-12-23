# frozen_string_literal: true

require 'cuprum/error'

module Spec::Errors
  class NotFound < Cuprum::Error
    def initialize(model_class:)
      @model_class = model_class
      message      = "#{model_class.name.split('::').last} not found"

      super(message: message)
    end

    attr_reader :model_class
  end
end
