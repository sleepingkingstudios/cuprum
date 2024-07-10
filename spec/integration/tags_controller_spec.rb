# frozen_string_literal: true

require 'support/tags_controller'

# @note Integration spec for Cuprum::ResultList.
RSpec.describe Spec::TagsController do
  subject(:controller) { described_class.new }

  let(:request)     { Spec::Request.new(params) }
  let(:params)      { { 'tags' => attributes } }
  let(:attributes)  { [] }
  let(:model_class) { Spec::Models::Tag }

  example_class 'Spec::Request', Struct.new(:params)

  describe '#bulk_create' do
    describe 'with an empty attributes array' do
      let(:attributes) { [] }
      let(:expected_json) do
        {
          'ok'   => true,
          'data' => {
            'tags' => []
          }
        }
      end

      it { expect(controller.bulk_create(request)).to be == expected_json }
    end

    describe 'with an attributes array with invalid values' do
      let(:attributes) do
        [
          { name: '' },
          { name: 'moist' },
          { name: '' }
        ]
      end
      let(:expected_error) do
        Cuprum::Errors::MultipleErrors.new(
          errors: attributes.map do |hsh|
            Spec::Errors::NotValid.new(
              errors:      model_class
                      .new(attributes: hsh)
                      .tap(&:valid?)
                      .errors,
              model_class:
            )
          end
        )
      end
      let(:expected_json) do
        {
          'ok'    => false,
          'data'  => {
            'tags' => Array.new(3)
          },
          'error' => expected_error.as_json
        }
      end

      it { expect(controller.bulk_create(request)).to be == expected_json }
    end

    describe 'with an attributes array with partially-valid values' do
      let(:attributes) do
        [
          { name: 'valid' },
          { name: 'moist' },
          { name: '' }
        ]
      end
      let(:expected_error) do
        Cuprum::Errors::MultipleErrors.new(
          errors: [
            nil,
            Spec::Errors::NotValid.new(
              errors:      model_class
                      .new(attributes: attributes[1])
                      .tap(&:valid?)
                      .errors,
              model_class:
            ),
            Spec::Errors::NotValid.new(
              errors:      model_class
                      .new(attributes: attributes[2])
                      .tap(&:valid?)
                      .errors,
              model_class:
            )
          ]
        )
      end
      let(:expected_value) do
        [
          model_class.new(attributes: attributes[0]).as_json,
          nil,
          nil
        ]
      end
      let(:expected_json) do
        {
          'ok'    => false,
          'data'  => {
            'tags' => expected_value
          },
          'error' => expected_error.as_json
        }
      end

      it { expect(controller.bulk_create(request)).to be == expected_json }
    end

    describe 'with an attributes array with valid values' do
      let(:attributes) do
        [
          { name: 'infantry' },
          { name: 'cavalry' },
          { name: 'artillery' }
        ]
      end
      let(:expected_value) do
        attributes.map do |hsh|
          model_class.new(attributes: hsh).as_json
        end
      end

      let(:expected_json) do
        {
          'ok'   => true,
          'data' => {
            'tags' => expected_value
          }
        }
      end

      it { expect(controller.bulk_create(request)).to be == expected_json }
    end
  end
end
