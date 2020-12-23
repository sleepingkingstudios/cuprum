# frozen_string_literal: true

require 'support/models/base'
require 'support/models/directory'

module Spec::Models
  class Post < Spec::Models::Base
    attribute :directory_id
    attribute :published
    attribute :title

    def initialize(attributes: {})
      super

      self.published = false
    end

    def directory
      @directory ||= Spec::Models::Directory.find(directory_id)
    end

    def update_attributes(attributes:)
      attributes = attributes.dup.tap { |hsh| hsh.delete(:published) }

      super
    end

    private

    def validation_errors
      errors = super

      errors << ['directory', 'must exist'] if directory.nil?

      errors << ['title', "can't be blank"] if title.nil? || title.empty?

      errors
    end
  end
end
