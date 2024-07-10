# frozen_string_literal: true

require 'cuprum/command'

require 'support/commands/create_model'
require 'support/commands/find_or_create_model_by'
require 'support/models/tag'
require 'support/models/tagging'

module Spec::Commands
  class AddTagToPost < Cuprum::Command
    private

    def create_tagging(attributes:)
      Spec::Commands::CreateModel
        .new(Spec::Models::Tagging)
        .call(attributes:)
    end

    def find_or_create_tag(attributes:)
      Spec::Commands::FindOrCreateModelBy
        .new(Spec::Models::Tag)
        .call(attributes:)
    end

    def process(post:, tag_attributes:)
      tag = step { find_or_create_tag(attributes: tag_attributes) }

      create_tagging(attributes: { post_id: post.id, tag_id: tag.id })
    end
  end
end
