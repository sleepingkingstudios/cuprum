# frozen_string_literal: true

require 'support/commands/build_model'
require 'support/models/book'

module Spec::Commands
  class BuildBook < BuildModel
    def initialize
      super(Spec::Models::Book)
    end
  end
end
