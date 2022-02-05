# frozen_string_literal: true

require 'forwardable'

require 'support/commands/bulk_create_model'
require 'support/models/tag'

module Spec
  class TagsController
    extend Forwardable

    def_delegators :@request,
      :params

    def bulk_create(request)
      @request = request
      results  =
        Spec::Commands::BulkCreateModel
        .new(Spec::Models::Tag)
        .call(params['tags'])

      build_response(results)
    end

    private

    def build_response(results)
      {
        'ok'   => results.success?,
        'data' => { 'tags' => results.value.map { |value| value&.as_json } }
      }
        .yield_self do |response|
          next response unless results.error

          response.merge('error' => results.error.as_json)
        end
    end
  end
end
