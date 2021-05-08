# frozen_string_literal: true

require 'cuprum/rspec/be_a_result'
require 'cuprum/rspec/be_callable'

require 'support/commands/find_or_create_model_by'
require 'support/models/tag'

RSpec.describe Spec::Commands::FindOrCreateModelBy do
  include Cuprum::RSpec::Matchers

  subject(:command) { described_class.new(model_class) }

  let(:model_class) { Spec::Models::Tag }

  after(:example) do
    Spec::Models::Tag.delete_all
  end

  describe '#call' do
    it 'should define the method' do
      expect(command)
        .to be_callable
        .with(0).arguments
        .and_keywords(:attributes)
    end

    context 'when a matching model does not exist' do
      # rubocop:disable RSpec/NestedGroups
      describe 'with invalid attributes' do
        let(:attributes) { { name: '' } }
        let(:result)     { command.call(attributes: attributes) }
        let(:validation_errors) do
          model_class.new(attributes: attributes).tap(&:valid?).errors
        end
        let(:expected_error) do
          Spec::Errors::NotValid.new(
            errors:      validation_errors,
            model_class: model_class
          )
        end

        it { expect(result).to be_a_failing_result.with_error(expected_error) }

        it 'should not create a tag' do
          expect { command.call(attributes: attributes) }
            .not_to change(model_class, :count)
        end
      end

      describe 'with valid attributes' do
        let(:attributes) { { name: 'wip' } }
        let(:result)     { command.call(attributes: attributes) }

        it { expect(result).to be_a_passing_result }

        it 'should return the tag' do
          expect(result.value).to be_a(model_class).and(
            have_attributes(attributes)
          )
        end

        it 'should create a tag' do
          expect { command.call(attributes: attributes) }
            .to change(model_class, :count)
            .by(1)
        end
      end
      # rubocop:enable RSpec/NestedGroups
    end

    context 'when a matching model exists' do
      let(:tag)        { Spec::Models::Tag.new(attributes: { name: 'wip' }) }
      let(:attributes) { { name: 'wip' } }
      let(:result)     { command.call(attributes: attributes) }

      before(:example) { tag.save }

      it { expect(result).to be_a_passing_result }

      it 'should return the tag' do
        expect(result.value).to be_a(model_class).and(
          have_attributes(attributes)
        )
      end

      it 'should not create a tag' do
        expect { command.call(attributes: attributes) }
          .not_to change(model_class, :count)
      end
    end
  end

  describe '#model_class' do
    include_examples 'should have reader', :model_class, -> { model_class }
  end
end
