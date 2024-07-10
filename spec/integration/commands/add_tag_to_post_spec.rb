# frozen_string_literal: true

require 'cuprum/rspec/be_a_result'
require 'cuprum/rspec/be_callable'

require 'support/commands/add_tag_to_post'
require 'support/models/post'
require 'support/models/tag'

RSpec.describe Spec::Commands::AddTagToPost do
  include Cuprum::RSpec::Matchers

  subject(:command) { described_class.new }

  after(:example) do
    Spec::Models::Post.delete_all
    Spec::Models::Tag.delete_all
    Spec::Models::Tagging.delete_all
  end

  describe '#call' do
    let(:post) { Spec::Models::Post.new(attributes: { title: 'Stem Bolt' }) }

    before(:example) { post.save }

    it 'should define the method' do
      expect(command)
        .to be_callable
        .with(0).arguments
        .and_keywords(:post, :tag_attributes)
    end

    context 'when the tag does not exist' do
      describe 'with invalid attributes' do
        let(:attributes) { { name: '' } }
        let(:result) do
          command.call(post:, tag_attributes: attributes)
        end
        let(:validation_errors) do
          Spec::Models::Tag.new(attributes:).tap(&:valid?).errors
        end
        let(:expected_error) do
          Spec::Errors::NotValid.new(
            errors:      validation_errors,
            model_class: Spec::Models::Tag
          )
        end

        it { expect(result).to be_a_failing_result.with_error(expected_error) }

        it 'should not create a tag' do
          expect { command.call(post:, tag_attributes: attributes) }
            .not_to change(Spec::Models::Tag, :count)
        end

        it 'should not create a tagging' do
          expect { command.call(post:, tag_attributes: attributes) }
            .not_to change(Spec::Models::Tagging, :count)
        end
      end

      describe 'with valid attributes' do
        let(:attributes) { { name: 'wip' } }
        let(:result) do
          command.call(post:, tag_attributes: attributes)
        end

        it { expect(result).to be_a_passing_result }

        it 'should create a tag' do
          expect { command.call(post:, tag_attributes: attributes) }
            .to change(Spec::Models::Tag, :count)
            .by(1)
        end

        it 'should set the tag attributes' do
          command.call(post:, tag_attributes: attributes)

          tag =
            Spec::Models::Tag.each.find { |item| item.attributes >= attributes }
          expect(tag).to be_a(Spec::Models::Tag)
        end

        it 'should create a tagging' do
          expect { command.call(post:, tag_attributes: attributes) }
            .to change(Spec::Models::Tagging, :count)
            .by(1)
        end

        it 'should return the tagging' do
          result = command.call(post:, tag_attributes: attributes)
          tag    =
            Spec::Models::Tag.each.find { |item| item.attributes >= attributes }

          expect(result.value).to be_a(Spec::Models::Tagging).and(
            have_attributes({ post_id: post.id, tag_id: tag.id })
          )
        end

        it 'should set the tagging attributes' do
          command.call(post:, tag_attributes: attributes)

          tag     =
            Spec::Models::Tag.each.find { |item| item.attributes >= attributes }
          tagging =
            Spec::Models::Tagging.each.find do |item|
              item.attributes >= { post_id: post.id, tag_id: tag.id }
            end
          expect(tagging).to be_a(Spec::Models::Tagging)
        end
      end
    end

    context 'when the tag exists' do
      let(:attributes) { { name: 'wip' } }
      let(:tag)        { Spec::Models::Tag.new(attributes:) }
      let(:result) do
        command.call(post:, tag_attributes: attributes)
      end

      before(:example) { tag.save }

      it { expect(result).to be_a_passing_result }

      it 'should not create a tag' do
        expect { command.call(post:, tag_attributes: attributes) }
          .not_to change(Spec::Models::Tag, :count)
      end

      it 'should create a tagging' do
        expect { command.call(post:, tag_attributes: attributes) }
          .to change(Spec::Models::Tagging, :count)
          .by(1)
      end

      it 'should return the tagging' do
        result = command.call(post:, tag_attributes: attributes)
        tag    =
          Spec::Models::Tag.each.find { |item| item.attributes >= attributes }

        expect(result.value).to be_a(Spec::Models::Tagging).and(
          have_attributes({ post_id: post.id, tag_id: tag.id })
        )
      end

      it 'should set the tagging attributes' do
        command.call(post:, tag_attributes: attributes)

        tag     =
          Spec::Models::Tag.each.find { |item| item.attributes >= attributes }
        tagging =
          Spec::Models::Tagging.each.find do |item|
            item.attributes >= { post_id: post.id, tag_id: tag.id }
          end
        expect(tagging).to be_a(Spec::Models::Tagging)
      end
    end
  end
end
