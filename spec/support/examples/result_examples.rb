# frozen_string_literal: true

require 'forwardable'

require 'rspec/sleeping_king_studios/concerns/shared_example_group'

module Spec::Examples
  module ResultExamples
    extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

    module EqualityExamples
      extend RSpec::SleepingKingStudios::Concerns::SharedExampleGroup

      shared_context 'with an object that wraps a result' do
        let(:other) { Spec::ResultWrapper.new(result) }

        example_class 'Spec::ResultWrapper', Struct.new(:result) do |klass|
          klass.extend Forwardable

          klass.def_delegators :result, :error, :status, :value
        end
      end

      shared_examples 'should compare the results' do |kwargs|
        let(:other_value)  { kwargs.fetch(:value) }
        let(:other_error)  { kwargs.fetch(:error) }
        let(:other_status) { kwargs.fetch(:status) }
        let(:result) do
          described_class.new(
            value:  other_value,
            error:  other_error,
            status: other_status
          )
        end
        let(:other) { defined?(super()) ? super() : result }
        let(:expected) do
          %i[error status value]
            .map { |method| instance.send(method) == other.send(method) }
            .reduce(true) { |memo, bool| memo && bool }
        end

        it { expect(instance == other).to be expected }
      end

      shared_examples 'should compare the results in each scenario' \
      do |scenarios|
        Spec::Matrix.new(self).evaluate(**scenarios) \
        do |value:, error:, status:|
          include_examples 'should compare the results',
            value:  value,
            error:  error,
            status: status
        end

        wrap_context 'with an object that wraps a result' do
          Spec::Matrix.new(self).evaluate(**scenarios) \
          do |value:, error:, status:|
            include_examples 'should compare the results',
              value:  value,
              error:  error,
              status: status
          end
        end
      end
    end

    shared_context 'when the result has a value' do
      let(:value) { 'returned value' }

      before(:example) { params[:value] = value }
    end

    shared_context 'when the result has an error' do
      let(:error) { Cuprum::Error.new(message: 'Something went wrong.') }

      before(:example) { params[:error] = error }
    end

    shared_context 'when the result has status: :failure' do
      before(:example) { params[:status] = :failure }
    end

    shared_context 'when the result has status: :success' do
      before(:example) { params[:status] = :success }
    end
  end
end
