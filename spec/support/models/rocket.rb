# frozen_string_literal: true

require 'support/models/base'

module Spec::Models
  class Rocket < Base
    attribute :launched
    attribute :name
  end
end
