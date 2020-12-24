# frozen_string_literal: true

require 'cuprum/command'

module Spec::Commands
  class SaveBookToCollection < Cuprum::Command
    def initialize(collection:)
      super()

      @collection = collection
    end

    attr_reader :collection

    private

    def process(book:)
      collection << book

      book
    end
  end
end
