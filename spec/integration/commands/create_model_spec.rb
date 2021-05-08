# frozen_string_literal: true

require 'cuprum/rspec/be_a_result'

require 'support/commands/create_model'
require 'support/models/directory'
require 'support/models/post'

RSpec.describe Spec::Commands::CreateModel do
  include Cuprum::RSpec::Matchers

  subject(:command) { described_class.new(model_class) }

  let(:model_class) { Spec::Models::Post }

  after(:example) do
    Spec::Models::Directory.delete_all
    Spec::Models::Post.delete_all
  end

  describe '#call' do
    describe 'with empty attributes' do
      let(:attributes) { {} }
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
    end

    describe 'with invalid attributes' do
      let(:directory) do
        Spec::Models::Directory.new(attributes: { name: 'widgets' })
      end
      let(:attributes) { { directory_id: directory.id } }
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

      before(:example) { directory.save }

      it { expect(result).to be_a_failing_result.with_error(expected_error) }

      it 'should not create a post' do
        expect { command.call(attributes: attributes) }
          .not_to change(model_class, :count)
      end
    end

    describe 'with valid attributes' do
      let(:directory) do
        Spec::Models::Directory.new(attributes: { name: 'widgets' })
      end
      let(:attributes) { { directory_id: directory.id, title: 'Stem Bolt' } }
      let(:result)     { command.call(attributes: attributes) }

      before(:example) { directory.save }

      it { expect(result).to be_a_passing_result }

      it 'should create a post' do
        expect { command.call(attributes: attributes) }
          .to change(model_class, :count)
          .by(1)
      end

      it 'should return the post' do
        expect(result.value).to be_a(model_class).and(
          have_attributes(attributes)
        )
      end
    end
  end

  describe '#model_class' do
    include_examples 'should have reader', :model_class, -> { model_class }
  end
end
