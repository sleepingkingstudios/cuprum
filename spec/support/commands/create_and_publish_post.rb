# frozen_string_literal: true

require 'cuprum/command'

require 'support/commands/create_model'
require 'support/commands/find_model'
require 'support/commands/publish_post'
require 'support/models/content'
require 'support/models/directory'
require 'support/models/post'

module Spec::Commands
  class CreateAndPublishPost < Cuprum::Command
    private

    def create_content(attributes:, post_id:)
      content_attributes =
        attributes.fetch(:content, {}).merge(post_id: post_id)

      Spec::Commands::CreateModel
        .new(Spec::Models::Content)
        .call(attributes: content_attributes)
    end

    def create_post(attributes:)
      post_attributes = attributes.dup.tap { |hsh| hsh.delete(:content) }

      Spec::Commands::CreateModel
        .new(Spec::Models::Post)
        .call(attributes: post_attributes)
    end

    def find_directory(id:)
      Spec::Commands::FindModel
        .new(Spec::Models::Directory)
        .call(id: id)
    end

    def process(attributes:)
      step { find_directory(id: attributes[:directory_id]) }

      post = step { create_post(attributes: attributes) }

      step { create_content(attributes: attributes, post_id: post.id) }

      step { publish_post(post: post) }

      success(post)
    end

    def publish_post(post:)
      Spec::Commands::PublishPost.new.call(post: post)
    end
  end
end
