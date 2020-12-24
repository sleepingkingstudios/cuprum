# frozen_string_literal: true

require 'support/models/base'
require 'support/models/post'

module Spec::Models
  class Content < Spec::Models::Base
    attribute :post_id
    attribute :text

    def post
      @post ||= Spec::Models::Post.find(post_id)
    end

    private

    def validation_errors
      errors = super

      errors << ['post', 'must exist'] if post.nil?

      errors << ['text', "can't be blank"] if text.nil? || text.empty?

      errors
    end
  end
end
