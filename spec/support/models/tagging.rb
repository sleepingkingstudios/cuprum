# frozen_string_literal: true

require 'support/models/base'
require 'support/models/post'
require 'support/models/tag'

module Spec::Models
  class Tagging < Spec::Models::Base
    attribute :post_id
    attribute :tag_id
  end
end
