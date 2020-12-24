# frozen_string_literal: true

require 'support/models/base'

module Spec::Models
  class Tag < Spec::Models::Base
    BLACKLIST = %w[moist].freeze

    attribute :name

    private

    def validation_errors
      errors = super

      errors << ['name', "can't be blank"] if name.nil? || name.empty?

      errors << ['name', 'is blacklisted'] if BLACKLIST.include?(name)

      errors
    end
  end
end
