# frozen_string_literal: true

require 'support/models/base'

module Spec::Models
  class Book < Base
    attribute :author
    attribute :publisher
    attribute :title
  end
end
