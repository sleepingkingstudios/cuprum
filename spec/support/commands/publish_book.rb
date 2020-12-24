# frozen_string_literal: true

require 'cuprum/command'

require 'support/models/book'

module Spec::Commands
  class PublishBook < Cuprum::Command
    def initialize(publisher:)
      super()

      @publisher = publisher
    end

    attr_reader :publisher

    private

    def process(book:)
      book.publisher = publisher

      success(book)
    end
  end
end
