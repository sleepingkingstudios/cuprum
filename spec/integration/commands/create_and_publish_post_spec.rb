# frozen_string_literal: true

require 'cuprum/rspec/be_a_result'

require 'support/commands/create_and_publish_post'
require 'support/models/directory'
require 'support/models/post'

RSpec.describe Spec::Commands::CreateAndPublishPost do
  subject(:command) { described_class.new }

  after(:example) do
    Spec::Models::Content.delete_all
    Spec::Models::Directory.delete_all
    Spec::Models::Post.delete_all
  end

  describe '#call' do
    context 'when the directory does not exist' do
      let(:directory_id) { '00000000-0000-0000-0000-000000000000' }
      let(:attributes)   { { directory_id: directory_id } }
      let(:result)       { command.call(attributes: attributes) }
      let(:expected_error) do
        Spec::Errors::NotFound.new(model_class: Spec::Models::Directory)
      end

      it { expect(result).to be_a_failing_result.with_error(expected_error) }

      it 'should not create a content' do
        expect { command.call(attributes: attributes) }
          .not_to change(Spec::Models::Post, :count)
      end

      it 'should not create a post' do
        expect { command.call(attributes: attributes) }
          .not_to change(Spec::Models::Post, :count)
      end
    end

    describe 'with invalid attributes' do
      let(:directory) do
        Spec::Models::Directory.new(attributes: { name: 'widgets' })
      end
      let(:attributes) { { directory_id: directory.id } }
      let(:result)     { command.call(attributes: attributes) }
      let(:validation_errors) do
        Spec::Models::Post.new(attributes: attributes).tap(&:valid?).errors
      end
      let(:expected_error) do
        Spec::Errors::NotValid.new(
          errors:      validation_errors,
          model_class: Spec::Models::Post
        )
      end

      before(:example) { directory.save }

      it { expect(result).to be_a_failing_result.with_error(expected_error) }

      it 'should not create a content' do
        expect { command.call(attributes: attributes) }
          .not_to change(Spec::Models::Content, :count)
      end

      it 'should not create a post' do
        expect { command.call(attributes: attributes) }
          .not_to change(Spec::Models::Post, :count)
      end
    end

    describe 'with missing content attributes' do
      let(:directory) do
        Spec::Models::Directory.new(attributes: { name: 'widgets' })
      end
      let(:attributes) do
        {
          directory_id: directory.id,
          title:        'Stem Bolt'
        }
      end
      let(:result) { command.call(attributes: attributes) }
      let(:validation_errors) do
        [['text', "can't be blank"]]
      end
      let(:expected_error) do
        Spec::Errors::NotValid.new(
          errors:      validation_errors,
          model_class: Spec::Models::Content
        )
      end

      before(:example) { directory.save }

      it { expect(result).to be_a_failing_result.with_error(expected_error) }

      it 'should not create a content' do
        expect { command.call(attributes: attributes) }
          .not_to change(Spec::Models::Content, :count)
      end

      it 'should create a post' do
        expect { command.call(attributes: attributes) }
          .to change(Spec::Models::Post, :count)
          .by(1)
      end

      it 'should not publish the post' do
        command.call(attributes: attributes)

        post = Spec::Models::Post.each.find { |item| item.title == 'Stem Bolt' }

        expect(post.published).to be false
      end
    end

    describe 'with invalid content attributes' do
      let(:directory) do
        Spec::Models::Directory.new(attributes: { name: 'widgets' })
      end
      let(:attributes) do
        {
          content:      { text: '' },
          directory_id: directory.id,
          title:        'Stem Bolt'
        }
      end
      let(:result) { command.call(attributes: attributes) }
      let(:validation_errors) do
        [['text', "can't be blank"]]
      end
      let(:expected_error) do
        Spec::Errors::NotValid.new(
          errors:      validation_errors,
          model_class: Spec::Models::Content
        )
      end

      before(:example) { directory.save }

      it { expect(result).to be_a_failing_result.with_error(expected_error) }

      it 'should not create a content' do
        expect { command.call(attributes: attributes) }
          .not_to change(Spec::Models::Content, :count)
      end

      it 'should create a post' do
        expect { command.call(attributes: attributes) }
          .to change(Spec::Models::Post, :count)
          .by(1)
      end

      it 'should not publish the post' do
        command.call(attributes: attributes)

        post = Spec::Models::Post.each.find { |item| item.title == 'Stem Bolt' }

        expect(post.published).to be false
      end
    end

    describe 'with valid attributes' do
      let(:directory) do
        Spec::Models::Directory.new(attributes: { name: 'widgets' })
      end
      let(:attributes) do
        {
          content:      { text: 'But is it self-sealing?' },
          directory_id: directory.id,
          title:        'Stem Bolt'
        }
      end
      let(:result) { command.call(attributes: attributes) }
      let(:expected_attributes) do
        {
          directory_id: directory.id,
          published:    true,
          title:        'Stem Bolt'
        }
      end

      before(:example) { directory.save }

      it { expect(result).to be_a_passing_result }

      it 'should create a content' do
        expect { command.call(attributes: attributes) }
          .to change(Spec::Models::Content, :count)
          .by(1)
      end

      it 'should set the content attributes' do
        post    = command.call(attributes: attributes).value
        content = Spec::Models::Content.each.find do |item|
          item.post_id == post.id
        end

        expect(content).to have_attributes(attributes[:content])
      end

      it 'should create a post' do
        expect { command.call(attributes: attributes) }
          .to change(Spec::Models::Post, :count)
          .by(1)
      end

      it 'should publish and return the post' do
        expect(result.value).to be_a(Spec::Models::Post).and(
          have_attributes(expected_attributes)
        )
      end

      it 'should set the post attributes' do
        post     = command.call(attributes: attributes).value
        reloaded = Spec::Models::Post.each.find do |item|
          item.id == post.id
        end

        expect(reloaded).to have_attributes(expected_attributes)
      end
    end
  end
end
