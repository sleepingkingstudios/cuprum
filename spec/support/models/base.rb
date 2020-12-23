# frozen_string_literal: true

require 'securerandom'

module Spec::Models
  class Base
    class << self
      alias_method :attribute, :attr_accessor

      def count
        models.count
      end

      def find(id)
        models.find { |item| item.id == id }
      end

      def persist(model)
        index = models.find_index { |item| item.id == model.id }

        models[index || models.size] = model

        model
      end

      private

      def models
        @models ||= []
      end
    end

    def initialize(attributes: {})
      attributes.each do |attr_name, value|
        send(:"#{attr_name}=", value)
      end

      self.id = SecureRandom.uuid if id.nil?
    end

    attribute :id

    attr_reader :errors

    def save
      self.class.persist(self)

      self
    end

    def valid?
      @errors = validation_errors

      errors.empty?
    end

    private

    def validation_errors
      []
    end
  end
end
