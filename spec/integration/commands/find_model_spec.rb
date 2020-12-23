# frozen_string_literal: true

require 'cuprum/rspec/be_a_result'

require 'support/commands/find_model'
require 'support/models/directory'

RSpec.describe Spec::Commands::FindModel do
  subject(:command) { described_class.new(model_class) }

  let(:model_class) { Spec::Models::Directory }

  describe '#call' do
    context 'when the model does not exist' do
      let(:directory_id) { '00000000-0000-0000-0000-000000000000' }
      let(:result)       { command.call(id: directory_id) }
      let(:expected_error) do
        Spec::Errors::NotFound.new(model_class: model_class)
      end

      it { expect(result).to be_a_failing_result.with_error(expected_error) }
    end

    context 'when the model exists' do
      let(:directory) do
        model_class.new(attributes: { name: 'widgets' })
      end
      let(:directory_id) { directory.id }
      let(:result)       { command.call(id: directory_id) }

      before(:example) { directory.save }

      it { expect(result).to be_a_passing_result.with_value(be == directory) }
    end
  end

  describe '#model_class' do
    include_examples 'should have reader', :model_class, -> { model_class }
  end
end
