# frozen_string_literal: true

require 'cuprum/command'

require 'support/commands/add_tag_to_post'
require 'support/commands/create_model'
require 'support/commands/find_model'
require 'support/commands/publish_post'
require 'support/models/content'
require 'support/models/directory'
require 'support/models/post'

module Spec::Commands
  class CreateAndPublishPost < Cuprum::Command
    private

    def add_tags_to_post(attributes:, post:)
      tag_names = attributes.fetch(:tags, [])
      command   = Spec::Commands::AddTagToPost.new

      tag_names.each do |tag_name|
        command.call(post:, tag_attributes: { name: tag_name })
      end
    end

    def create_content(attributes:, post_id:)
      content_attributes =
        attributes.fetch(:content, {}).merge(post_id:)

      Spec::Commands::CreateModel
        .new(Spec::Models::Content)
        .call(attributes: content_attributes)
    end

    def create_post(attributes:)
      post_attributes = attributes.dup.tap do |hsh|
        hsh.delete(:content)
        hsh.delete(:tags)
      end

      Spec::Commands::CreateModel
        .new(Spec::Models::Post)
        .call(attributes: post_attributes)
    end

    def find_directory(id:)
      Spec::Commands::FindModel
        .new(Spec::Models::Directory)
        .call(id:)
    end

    def process(attributes:)
      step { find_directory(id: attributes[:directory_id]) }

      post = step { create_post(attributes:) }

      step { create_content(attributes:, post_id: post.id) }

      step { publish_post(post:) }

      add_tags_to_post(attributes:, post:)

      success(post)
    end

    def publish_post(post:)
      Spec::Commands::PublishPost.new.call(post:)
    end
  end
end
