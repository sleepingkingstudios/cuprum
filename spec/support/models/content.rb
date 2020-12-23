# frozen_string_literal: true

require 'support/models/base'
require 'support/models/post'

module Spec::Models
  class Content < Spec::Models::Base
    attribute :post_id
    attribute :text
  end
end
