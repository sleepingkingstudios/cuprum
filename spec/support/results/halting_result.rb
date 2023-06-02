# frozen_string_literal: true

require 'cuprum/result'

module Spec::Results
  class HaltingResult < Cuprum::Result
    STATUSES = [*Cuprum::Result::STATUSES, :halted].freeze

    # @return [Boolean] true if the result status is :halted, otherwise false.
    def halted?
      @status == :halted
    end
  end
end
