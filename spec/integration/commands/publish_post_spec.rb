# frozen_string_literal: true

require 'cuprum/rspec/be_a_result'

require 'support/commands/publish_post'
require 'support/models/content'
require 'support/models/directory'
require 'support/models/post'

RSpec.describe Spec::Commands::PublishPost do
  include Cuprum::RSpec::Matchers

  subject(:command) { described_class.new }

  after(:example) do
    Spec::Models::Content.delete_all
    Spec::Models::Directory.delete_all
    Spec::Models::Post.delete_all
  end

  describe '#call' do
    let(:directory) do
      Spec::Models::Directory.new(attributes: { name: 'widgets' })
    end
    let(:post) do
      Spec::Models::Post.new(
        attributes: { directory_id: directory.id, title: 'Stem Bolt' }
      )
    end

    before(:example) do
      directory.save
      post.save
    end

    context 'when the post does not have a content' do
      let(:result) { command.call(post: post) }
      let(:expected_error) do
        Spec::Errors::NotFound.new(model_class: Spec::Models::Content)
      end

      it { expect(result).to be_a_failing_result.with_error(expected_error) }

      it 'should not publish the post' do
        command.call(post: post)

        reloaded = Spec::Models::Post.find(post.id)

        expect(reloaded.published).to be false
      end
    end

    context 'when the post has a content' do
      let(:content) do
        Spec::Models::Content.new(
          attributes: {
            post_id: post.id,
            text:    'But is it self-sealing?'
          }
        )
      end
      let(:result) { command.call(post: post) }

      before(:example) { content.save }

      it { expect(result).to be_a_passing_result.with_value(post) }

      it 'should publish the post' do
        command.call(post: post)

        reloaded = Spec::Models::Post.find(post.id)

        expect(reloaded.published).to be true
      end
    end
  end
end
