# frozen_string_literal: true

require 'cuprum/result'

module Spec::Results
  class ResultWithChecksum < Cuprum::Result
    def initialize(checksum: nil, error: nil, status: nil, value: nil)
      super(error:, status:, value:)

      @checksum = checksum
    end

    attr_reader :checksum

    def properties
      super.merge(checksum:)
    end
    alias_method :to_h, :properties
  end
end
