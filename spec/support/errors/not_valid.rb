# frozen_string_literal: true

require 'cuprum/error'

module Spec::Errors
  class NotValid < Cuprum::Error
    def initialize(errors:, model_class:)
      @model_class = model_class
      @errors      = errors
      message      = build_message

      super(message: message)
    end

    attr_reader :errors

    attr_reader :model_class

    private

    def build_message
      message = +"#{model_class.name.split('::').last} not valid"

      return message if errors.empty?

      message << ': '
      message << errors.map { |err| err.join(' ') }.join(', ')
    end
  end
end
