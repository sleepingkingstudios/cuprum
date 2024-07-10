# frozen_string_literal: true

require 'cuprum/rspec/be_a_result'
require 'cuprum/rspec/be_callable'

require 'support/commands/find_one_association'
require 'support/models/content'

RSpec.describe Spec::Commands::FindOneAssociation do
  include Cuprum::RSpec::Matchers

  subject(:command) do
    described_class.new(foreign_key:, model_class:)
  end

  let(:foreign_key) { :post_id }
  let(:model_class) { Spec::Models::Content }

  after(:example) do
    Spec::Models::Content.delete_all
  end

  describe '#call' do
    it 'should define the method' do
      expect(command)
        .to be_callable
        .with(0).arguments
        .and_keywords(:id)
    end

    context 'when the associated model does not exist' do
      let(:post_id) { '00000000-0000-0000-0000-000000000000' }
      let(:result)  { command.call(id: post_id) }
      let(:expected_error) do
        Spec::Errors::NotFound.new(model_class:)
      end

      it { expect(result).to be_a_failing_result.with_error(expected_error) }
    end

    context 'when the model exists' do
      let(:post_id) { '00000000-0000-0000-0000-000000000000' }
      let(:content) do
        Spec::Models::Content.new(attributes: { post_id: })
      end
      let(:result) { command.call(id: post_id) }

      before(:example) { content.save }

      it { expect(result).to be_a_passing_result.with_value(be == content) }
    end
  end

  describe '#foreign_key' do
    include_examples 'should have reader', :foreign_key, -> { foreign_key }
  end

  describe '#model_class' do
    include_examples 'should have reader', :model_class, -> { model_class }
  end
end
