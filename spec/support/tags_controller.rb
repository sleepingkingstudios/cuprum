# frozen_string_literal: true

require 'forwardable'

require 'support/commands/bulk_create_model'
require 'support/models/tag'

module Spec
  class TagsController
    extend Forwardable

    class BulkCreateTags < Spec::Commands::BulkCreateModel
      def initialize
        super(Spec::Models::Tag)
      end

      private

      def build_result_list(results)
        Cuprum::ResultList.new(
          *results,
          value: { 'tags' => results.map(&:value) }
        )
      end
    end

    def_delegators :@request,
      :params

    def bulk_create(request)
      @request = request
      results  = BulkCreateTags.new.call(params['tags'])

      build_response(results)
    end

    private

    def build_response(results)
      {
        'ok'   => results.success?,
        'data' => results.value.transform_values do |ary|
          ary.map { |item| item&.as_json }
        end
      }
        .yield_self do |response|
          next response unless results.error

          response.merge('error' => results.error.as_json)
        end
    end
  end
end
