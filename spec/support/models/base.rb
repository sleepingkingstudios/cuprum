# frozen_string_literal: true

require 'securerandom'

module Spec::Models
  class Base
    class << self
      def attribute(attr_name)
        attributes << attr_name

        attr_accessor attr_name
      end

      def attributes
        @attributes ||= []
      end

      def count
        models.count
      end

      def delete_all
        @models = []
      end

      def each
        return enum_for(:each) unless block_given?

        models.each { |item| yield item.dup }
      end

      def find(id)
        models.find { |item| item.id == id }.dup
      end

      def persist(model)
        index = models.find_index { |item| item.id == model.id }

        models[index || models.size] = model.dup

        model
      end

      private

      def models
        @models ||= []
      end
    end

    def initialize(attributes: {})
      update_attributes(attributes: attributes)

      self.id = SecureRandom.uuid if id.nil?
    end

    attribute :id

    attr_reader :errors

    def ==(other)
      other.class == self.class && other.attributes == attributes
    end

    def as_json
      attributes.transform_keys(&:to_s)
    end

    def attributes
      self.class.attributes.each.with_object({}) do |attr_name, hsh|
        hsh[attr_name] = send(attr_name)
      end
    end

    def save
      self.class.persist(self)

      self
    end

    def update_attributes(attributes:)
      attributes.each do |attr_name, value|
        send(:"#{attr_name}=", value)
      end
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
