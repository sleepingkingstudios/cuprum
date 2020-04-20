# frozen_string_literal: true

require 'cuprum'

module Cuprum
  # Helper methods for generating Cuprum result objects.
  module ResultHelpers
    private

    def build_result(error: nil, status: nil, value: nil)
      Cuprum::Result.new(error: error, status: status, value: value)
    end

    def failure(error)
      build_result(error: error)
    end

    def success(value)
      build_result(value: value)
    end
  end
end
