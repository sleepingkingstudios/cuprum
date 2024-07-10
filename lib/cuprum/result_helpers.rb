# frozen_string_literal: true

require 'cuprum'

module Cuprum
  # Helper methods for generating Cuprum result objects.
  module ResultHelpers
    private

    def build_result(error: nil, status: nil, value: nil)
      Cuprum::Result.new(error:, status:, value:)
    end

    def failure(error)
      build_result(error:)
    end

    def success(value)
      build_result(value:)
    end
  end
end
