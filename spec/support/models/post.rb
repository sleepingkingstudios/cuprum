# frozen_string_literal: true

require 'support/models/base'
require 'support/models/directory'

module Spec::Models
  class Post < Spec::Models::Base
    attribute :directory_id
    attribute :title

    def directory
      @directory ||= Spec::Models::Directory.find(directory_id)
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
