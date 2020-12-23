# frozen_string_literal: true

require 'cuprum/command'

require 'support/commands/find_one_association'
require 'support/models/content'

module Spec::Commands
  class PublishPost < Cuprum::Command
    private

    def ensure_post_has_content(post:)
      Spec::Commands::FindOneAssociation
        .new(foreign_key: :post_id, model_class: Spec::Models::Content)
        .call(id: post.id)
    end

    def process(post:)
      step { ensure_post_has_content(post: post) }

      post.published = true

      post.save

      success(post)
    end
  end
end
